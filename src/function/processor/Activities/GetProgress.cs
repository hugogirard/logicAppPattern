using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;
using processor.Model;
using processor.Services;

namespace processor
{
    public class GetProgress
    {
        private readonly IBlobService _blobService;

        public GetProgress(IBlobService blobService)
        {
            _blobService = blobService;
        }

        // [FunctionName("GetCopyProgress")]
        // public async Task<BlobStatus> GetCopyProgress([ActivityTrigger] string filename,ILogger log)
        // {
        //     try
        //     {
                
        //     }
        //     catch (Exception ex)
        //     {
        //         log.LogError(ex.Message);
        //         throw ex;
        //     }
            
        // }

    }    
}