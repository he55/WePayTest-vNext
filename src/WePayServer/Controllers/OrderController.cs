using System.Linq;
using System.Threading.Tasks;
using WePayServer.Data;
using WePayServer.Models;
using WePayServer.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace WePayServer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController : ControllerBase
    {
        private readonly ILogger<OrderController> _logger;
        private readonly IConfiguration _configuration;
        private readonly WePayContext _context;
        private readonly WeChatService _wechatService;

        private static readonly List<WePayOrder> WePayOrders = new List<WePayOrder>();

        public OrderController(
            ILogger<OrderController> logger,
            IConfiguration configuration,
            WePayContext context,
            WeChatService wechatService)
        {
            _logger = logger;
            _configuration = configuration;
            _context = context;
            _wechatService = wechatService;
        }

        public class OrderCodeDto
        {
            public long Id { get; set; }
            public string OrderCode { get; set; } = "";
        }

        [HttpPost("/wepay")]
        public ActionResult<WePayOrder> WePay(OrderCodeDto orderCodeDto)
        {
            if (orderCodeDto.Id != 0)
            {
                WePayOrder wePayOrder = WePayOrders.Where(x => x.Id == orderCodeDto.Id).FirstOrDefault();
                if (wePayOrder != null)
                {
                    wePayOrder.OrderCode = orderCodeDto.OrderCode;
                    WePayOrders.Remove(wePayOrder);
                }
            }

            WePayOrder order = WePayOrders.Where(x => string.IsNullOrEmpty(x.OrderCode)).FirstOrDefault();
            if (order != null)
            {
                return order;
            }
            return NoContent();
        }

        [HttpPost("/postorder")]
        public async Task<ResultModel> PostOrder(WePayMessageDto messageDto)
        {
            Dictionary<string, string> messageInfo = _wechatService.GetMessageInfo(messageDto.Message);
            string orderId = messageInfo["detail_content_value_1"];

            WePayOrder order = await _context.WePayOrders
                .Where(x => x.OrderId == orderId)
                .FirstOrDefaultAsync();
            if (order != null)
            {
                order.IsPay = true;
                order.OrderMessage = messageDto.Message;
                await _context.SaveChangesAsync();
            }

            return this.ResultSuccess(null);
        }

        [HttpGet("{id:long}")]
        public async Task<ResultModel> GetOrderAsync(long id)
        {
            WePayOrder order = await _context.WePayOrders
                .Where(x => x.Id == id)
                .FirstOrDefaultAsync();
            if (order == null)
            {
                return this.ResultFail("没有找到指定订单");
            }
            return this.ResultSuccess(order);
        }

        [HttpPost]
        public async Task<ResultModel> CreateOrderAsync(WePayOrderDto order)
        {
            if (order.OrderAmount < 0.01m)
            {
                return this.ResultFail("参数错误，金额不能小于 0.01 元");
            }

            if (order.OrderId.Length == 0)
            {
                return this.ResultFail("参数错误，订单号长度不能为 0");
            }

            if (await _context.WePayOrders.AnyAsync(x => x.OrderId == order.OrderId))
            {
                return this.ResultFail("订单号已经存在");
            }


            WePayOrder wePayOrder = new WePayOrder
            {
                OrderId = order.OrderId,
                OrderAmount = order.OrderAmount
            };
            _context.WePayOrders.Add(wePayOrder);
            await _context.SaveChangesAsync();

            WePayOrders.Add(wePayOrder);

            for (int i = 0; i < 20; i++)
            {
                await Task.Delay(300);
                if (!string.IsNullOrEmpty(wePayOrder.OrderCode))
                {
                    await _context.SaveChangesAsync();
                    return this.ResultSuccess(wePayOrder);
                }
            }
            return this.ResultFail("订单生成失败");
        }
    }
}
