namespace Microsoft.AspNetCore.Mvc
{
    public static class ControllerBaseExtension
    {
        public static ResultModel ResultSuccess(this ControllerBase _, object? result, int code = 0, string message = "")
        {
            return new ResultModel
            {
                Success = true,
                Code = code,
                Message = message,
                Result = result
            };
        }

        public static ResultModel ResultFail(this ControllerBase _, string message, int code = 1, object? result = null)
        {
            return new ResultModel
            {
                Success = false,
                Code = code,
                Message = message,
                Result = result
            };
        }
    }

    public struct ResultModel
    {
        public bool Success { get; set; }
        public int Code { get; set; }
        public string Message { get; set; }
        public object? Result { get; set; }
    }
}
