package com.ruoyi.system.service.mes.sys.integration;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import com.alibaba.fastjson2.JSONObject;

/**
 * ERP 回调 HTTP 客户端
 * 使用 JDK 自带 HttpClient，不引入第三方 HTTP 依赖
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@Component
public class ErpClient
{
    private static final Logger log = LoggerFactory.getLogger(ErpClient.class);

    private static final Duration CONNECT_TIMEOUT = Duration.ofSeconds(5);
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(15);

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(CONNECT_TIMEOUT)
            .build();

    /**
     * POST JSON 并校验业务码
     *
     * @throws RuntimeException 网络异常、HTTP 非 2xx、业务码非 200
     */
    public void post(String baseUrl, String path, String apiKey, String payload)
    {
        String url = join(baseUrl, path);
        HttpRequest.Builder builder = HttpRequest.newBuilder(URI.create(url))
                .timeout(REQUEST_TIMEOUT)
                .header("Content-Type", "application/json;charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8));
        if (apiKey != null && !apiKey.isEmpty())
        {
            builder.header("X-API-Key", apiKey);
        }
        try
        {
            HttpResponse<String> resp = httpClient.send(builder.build(),
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (resp.statusCode() / 100 != 2)
            {
                throw new RuntimeException("HTTP " + resp.statusCode() + ": " + abbreviate(resp.body()));
            }
            String body = resp.body();
            if (body == null || body.isEmpty())
            {
                return;
            }
            JSONObject json = JSONObject.parseObject(body);
            Integer code = json.getInteger("code");
            if (code != null && code != 200)
            {
                throw new RuntimeException("ERP返回失败: " + json.getString("msg"));
            }
        }
        catch (InterruptedException e)
        {
            Thread.currentThread().interrupt();
            throw new RuntimeException("调用ERP被中断");
        }
        catch (RuntimeException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            log.warn("调用ERP失败, url={}", url, e);
            throw new RuntimeException("调用ERP失败: " + e.getMessage());
        }
    }

    private String join(String baseUrl, String path)
    {
        String base = baseUrl == null ? "" : baseUrl.trim();
        while (base.endsWith("/"))
        {
            base = base.substring(0, base.length() - 1);
        }
        String suffix = path.startsWith("/") ? path : "/" + path;
        return base + suffix;
    }

    private String abbreviate(String text)
    {
        if (text == null) return "";
        return text.length() > 300 ? text.substring(0, 300) + "..." : text;
    }
}
