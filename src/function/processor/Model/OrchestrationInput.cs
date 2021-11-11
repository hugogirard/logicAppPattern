namespace processor.Model
{
    public class OrchestrationInput 
    {
        public string SourceFileName { get; set; } 

        public string DestinationFileName { get; set; }

        public int WaitingTime { get; set; }

        public string Mode { get; set; }
    }
}