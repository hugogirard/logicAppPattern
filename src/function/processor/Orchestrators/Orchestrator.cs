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
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using processor.Model;

namespace processor
{    
    public class Orchestrator
    {
        [FunctionName("ProcessorOrchestrator")]
        public async Task RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            string filename = context.GetInput<string>();

            BlobStatus status = await context.CallActivityAsync<BlobStatus>("StartCopy", filename);

            //do
            //{
                

            //} while (true);

            //var outputs = new List<string>();

            //// Replace "hello" with the name of your Durable Activity Function.
            //outputs.Add(await context.CallActivityAsync<string>("Function1_Hello", "Tokyo"));
            //outputs.Add(await context.CallActivityAsync<string>("Function1_Hello", "Seattle"));
            //outputs.Add(await context.CallActivityAsync<string>("Function1_Hello", "London"));

            //// returns ["Hello Tokyo!", "Hello Seattle!", "Hello London!"]
            //return outputs;
        }
    }
}
