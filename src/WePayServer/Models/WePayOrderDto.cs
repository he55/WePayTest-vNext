namespace WePayServer
{
    public class WePayOrderDto
    {
        public long Id { get; set; }
        public bool IsSend { get; set; }
        public string OrderId { get; set; } = null!;
        public decimal OrderAmount { get; set; }
        public string OrderCode { get; set; } = "";
    }
}
