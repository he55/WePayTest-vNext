using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WePayServer.Models;

namespace WePayServer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController : ControllerBase
    {
        private static readonly List<WePayOrder> WePayOrders = new List<WePayOrder>();

        private readonly WePayContext _context;

        public OrderController(WePayContext context)
        {
            _context = context;
        }

        [HttpGet("/getOrderTask")]
        public List<WePayOrder> GetOrderTask()
        {
            List<WePayOrder> wePayOrders = WePayOrders.Where(x => !x.IsSend)
                .OrderBy(x => x.Id)
                .ToList();

            wePayOrders.ForEach(x => x.IsSend = true);

            return wePayOrders;
        }

        [HttpPost("/postOrderTask")]
        public ResultModel PostOrderTask(OrderCodeDto orderCodeDto)
        {
            WePayOrder wePayOrder = WePayOrders.FirstOrDefault(x => x.Id == orderCodeDto.Id);
            if (wePayOrder != null)
            {
                wePayOrder.OrderCode = orderCodeDto.OrderCode;
                WePayOrders.Remove(wePayOrder);
            }

            return this.ResultSuccess();
        }

        [HttpPost("/postorder")]
        public async Task<ResultModel> PostOrder(WePayMessageDto messageDto)
        {
            Dictionary<string, string> messageInfo = WeChatService.GetMessageInfo(messageDto.Message);
            string orderId = messageInfo["detail_content_value_1"];

            WePayOrder order = await _context.WePayOrders.FirstOrDefaultAsync(x => x.OrderId == orderId);
            if (order != null)
            {
                order.IsPay = true;
                order.OrderMessage = messageDto.Message;
                await _context.SaveChangesAsync();
            }

            return this.ResultSuccess();
        }

        [HttpGet("{id:long}")]
        public async Task<ResultModel> GetOrderAsync(long id)
        {
            WePayOrder order = await _context.WePayOrders.FirstOrDefaultAsync(x => x.Id == id);
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

            if (string.IsNullOrWhiteSpace(order.OrderId))
            {
                return this.ResultFail("参数错误，订单号不能为空");
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
                //await Task.Delay(300);
                wePayOrder.OrderCode = wePayOrder.OrderId;
                if (!string.IsNullOrWhiteSpace(wePayOrder.OrderCode))
                {
                    await _context.SaveChangesAsync();
                    return this.ResultSuccess(wePayOrder);
                }
            }
            return this.ResultFail("订单生成失败");
        }
    }
}
