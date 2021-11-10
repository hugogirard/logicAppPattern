/*
* Notice: Any links, references, or attachments that contain sample scripts, code, or commands comes with the following notification.
*
* This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
* THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
* INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
*
* We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
* provided that You agree:
*
* (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
* (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
* (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits,
* including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
*
* Please note: None of the conditions outlined in the disclaimer above will superseded the terms and conditions contained within the Premier Customer Services Description.
*
* DEMO POC - "AS IS"
*/
using Azure.Storage.Blobs.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using processor.Model;
using System.Threading;
using Microsoft.Extensions.Logging;

namespace processor
{    
    public class Orchestrator
    {
        [FunctionName("ProcessorOrchestrator")]
        public async Task RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext context, ILogger log)
        {
            string filename = context.GetInput<string>();

            try
            {
                BlobStatus status = await context.CallActivityAsync<BlobStatus>("StartCopy", filename);
                
                bool getResult = false;
                int waitingTime = -1;                           
                string message = string.Empty;
                do
                {
                    if (waitingTime >= 9)
                    {
                        waitingTime = 10;
                    }
                    else 
                    {
                        waitingTime += 2;
                    }
                                    
                    switch (status.CopyStatus)
                    {
                        case CopyStatus.Pending:
                            DateTime deadline = context.CurrentUtcDateTime.Add(TimeSpan.FromMinutes(waitingTime));
                            await context.CreateTimer(deadline,CancellationToken.None);
                            status = await context.CallActivityAsync<BlobStatus>("GetCopyProgress", status.Filename);
                            break;
                        case CopyStatus.Success:
                            // Send result in storage queue
                            message = $"Copy of file {filename} success with name {status.Filename}.  Completed on: ${status.CopyCompletedOn}";
                            getResult = true;
                            break;
                        default:
                            // Send result in storage queue
                            message = $"Copy of file {filename} failed with status {status.CopyStatus}.";
                            getResult = true;
                            break;
                    }

                    if (getResult)
                    {
                        // Call activity to add in queue here 
                        await context.CallActivityAsync("QueueOutput", message);                       
                    }
                }
                while (!getResult);                 
            }
            catch (Exception ex)
            {

                log.LogError(ex,ex.Message);
                throw;
            }
            finally 
            {
                await context.CallActivityAsync("BreakLease", filename);
            }


        }
    }
}
