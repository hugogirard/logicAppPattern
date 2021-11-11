using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net.Mail;
using System.Net;

namespace Email
{
    public static class SendResultEmail
    {
        [FunctionName("SendResultEmail")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var metadata = new Dictionary<string, string>
            {
                ["emailFrom"] = "noreply@cfca.gov",
                ["emailTo"] = "test@outlook.com",
                ["subject"] = $"Copy result"
            };

            var smtpClient = new SmtpClient("52.224.128.76")
            {
                Port = 1025,
                Credentials = new NetworkCredential("",""),
                EnableSsl = false
            };
            MailMessage message = new MailMessage("noreply@cfca.gov", "test@outlook.com");
            message.Body = "This is a test email message sent by an application. ";
            message.Subject = "test message 1";
            message.SubjectEncoding = System.Text.Encoding.UTF8;
            string userState = "test message1";
            smtpClient.SendAsync(message,userState);
            
            return new OkObjectResult("Yeah");
        }
    }
}
