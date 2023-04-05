namespace WePayServer
{
    public class OrderCodeDto
    {
        public long Id { get; set; }
        public string OrderId { get; set; } = null!;
        public decimal OrderAmount { get; set; }
        public string OrderCode { get; set; } = "";
    }
}
