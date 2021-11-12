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
using Newtonsoft.Json;

namespace processor
{    
    public class Orchestrator
    {
        const string COPY = "COPY";
        const string PULLING = "PULLING";

        [FunctionName("ProcessorOrchestrator")]
        public async Task RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext context, ILogger log)
        {
            var serializedInput = context.GetInput<string>();
            var parameters = JsonConvert.DeserializeObject<OrchestrationInput>(serializedInput);
            
            if (string.IsNullOrEmpty(parameters.Mode)) 
            {
                parameters.Mode = COPY;
            }

            if (parameters.WaitingTime == 0)
                parameters.WaitingTime = 1;

            try
            {

                if (parameters.Mode == COPY)
                {
                    log.LogInformation($"Starting copy of file {parameters.SourceFileName}");
                    
                    BlobStatus status = await context.CallActivityAsync<BlobStatus>("StartCopy", parameters.SourceFileName);
                    parameters.Mode = PULLING;
                    parameters.WaitingTime = 3;
                    parameters.DestinationFileName = status.Filename;
                    
                    log.LogInformation($"Filename in destination storage {status.Filename}");

                    DateTime deadline = context.CurrentUtcDateTime.Add(TimeSpan.FromSeconds(15));
                    await context.CreateTimer(deadline,CancellationToken.None);
                    context.ContinueAsNew(JsonConvert.SerializeObject(parameters));
                }
                else 
                {
                    log.LogInformation($"Pulling result of copied file ${parameters.SourceFileName}");
                    var status = await context.CallActivityAsync<BlobStatus>("GetCopyProgress", parameters.DestinationFileName);
                    string message = string.Empty;
                    bool getResult = false;
                    switch (status.CopyStatus)
                    {
                        case CopyStatus.Pending:
                            
                            log.LogInformation($"File {parameters.DestinationFileName} still in pending copy state");

                            DateTime deadline = context.CurrentUtcDateTime.Add(TimeSpan.FromMinutes(parameters.WaitingTime));
                            await context.CreateTimer(deadline,CancellationToken.None);

                            if (parameters.WaitingTime < 10) 
                            {
                                parameters.WaitingTime += 2;
                            }
                            else 
                            {
                                parameters.WaitingTime = 10;
                            }
                            context.ContinueAsNew(JsonConvert.SerializeObject(parameters));
                            break;
                        case CopyStatus.Success:

                            log.LogInformation($"File {parameters.DestinationFileName} successfully copied");

                            // Send result in storage queue
                            message = $"Copy of file {parameters.SourceFileName} success with name {status.Filename}.  Completed on: ${status.CopyCompletedOn}";
                            getResult = true;
                            break;
                        default:
                            
                            log.LogError($"Copy failed for file {parameters.DestinationFileName} with status {status.CopyStatus}");
                            
                            // Send result in storage queue
                            message = $"Copy of file {parameters.SourceFileName} failed with status {status.CopyStatus}.";
                            getResult = true;
                            break;
                    }

                    if (getResult)
                    {
                        log.LogInformation($"Sending message to queue");
                        // Call activity to add in queue here 
                        await context.CallActivityAsync("QueueOutput", message); 
                        await context.CallActivityAsync("BreakLease", parameters.SourceFileName);                      
                    }                    
                }
                                            
            }
            catch (Exception ex)
            {

                log.LogError(ex,ex.Message);
                await context.CallActivityAsync("BreakLease", parameters.SourceFileName);
                throw;
            }

        }
    }
}
