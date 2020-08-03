namespace WePayServer.Models
{
    public class WePayMessageDto
    {
        public int CreateTime { get; set; }
        public string MessageId { get; set; } = null!;
        public string Message { get; set; } = null!;
    }
}
