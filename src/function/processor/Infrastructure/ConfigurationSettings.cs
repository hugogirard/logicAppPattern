using System;
using System.Collections.Generic;
using System.Text;

namespace processor.Infrastructure
{
    public class ConfigurationSettings
    {
        public string SourceStorageCnxString { get; set; }

        public string SourceStorageContainer {  get; set;}

        public string TargetStorageCnxString {  get; set; }

        public string TargetStorageContainer { get; set; }
    }
}
