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
* including attorneys� fees, that arise or result from the use or distribution of the Sample Code.
*
* Please note: None of the conditions outlined in the disclaimer above will superseded the terms and conditions contained within the Premier Customer Services Description.
*
* DEMO POC - "AS IS"
*/
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using processor.Infrastructure;
using processor.Model;

namespace processor.Services
{
    public class BlobService : IBlobService
    {
        private readonly ILogger<BlobService> _log;
        private IDictionary<string, BlobContainerClient> _instances;

        struct KEYS
        {
            public const string SOURCE = "StorageSource";
            public const string DESTINATION = "StorageDestination";
        }

        public BlobService(IOptions<ConfigurationSettings> options, ILogger<BlobService> log)
        {
            var blobServiceClient = new BlobServiceClient(options.Value.SourceStorageCnxString);
            var containerClient = blobServiceClient.GetBlobContainerClient(options.Value.SourceStorageContainer);

            _instances = new Dictionary<string, BlobContainerClient>();
            _instances.Add(KEYS.SOURCE, containerClient);

            blobServiceClient = new BlobServiceClient(options.Value.TargetStorageCnxString);
            containerClient = blobServiceClient.GetBlobContainerClient(options.Value.TargetStorageContainer);

            _instances.Add(KEYS.DESTINATION, containerClient);

            _log = log;
        }

        public async Task<BlobStatus> CopyBlobAsync(string filename)
        {
            // Validate the source exists and get a lease
            var containerSourceClient = _instances[KEYS.SOURCE];
            var sourceBlob = containerSourceClient.GetBlobClient(filename);
            BlobLeaseClient lease = null;
            var blobStatus = new BlobStatus();

            try
            {
                if (await sourceBlob.ExistsAsync())
                {
                    // Lease the blob to avoid modification of it during the copy
                    lease = sourceBlob.GetBlobLeaseClient();

                    // Create infinite lease
                    await lease.AcquireAsync(TimeSpan.FromSeconds(-1));
              
                    // Get the source blobs properties
                    BlobProperties sourceBlobProperties = await sourceBlob.GetPropertiesAsync();
                    _log.LogInformation($"Lease state: ${sourceBlobProperties.LeaseState}");

                    // Create the destination blob
                    var containerDestinationClient = _instances[KEYS.DESTINATION];
                    var destinationBlob = containerDestinationClient.GetBlobClient($"{Guid.NewGuid()}");

                    var operation = await destinationBlob.StartCopyFromUriAsync(sourceBlob.Uri);
                    BlobProperties destProperties = await destinationBlob.GetPropertiesAsync();

                    blobStatus.CopyStatus = destProperties.CopyStatus;
                    blobStatus.CopyProgress = destProperties.CopyProgress;
                    blobStatus.CopyCompletedOn = destProperties.CopyCompletedOn;
                    blobStatus.ContentLength = destProperties.ContentLength;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            // finally 
            // {
            //     // Break the lease if this is the problem
            //     BlobProperties sourceBlobProperties = await sourceBlob.GetPropertiesAsync();
            //     if (sourceBlobProperties.LeaseState == LeaseState.Leased && lease != null)
            //     {
            //         await lease.BreakAsync();
            //     }
            // }

            return blobStatus;


        }
    }
}