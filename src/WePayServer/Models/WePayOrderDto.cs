namespace WePayServer.Models
{
    public class WePayOrderDto
    {
        public string OrderId { get; set; } = null!;
        public decimal OrderAmount { get; set; }
        public string OrderCode { get; set; } = "";
    }
}
