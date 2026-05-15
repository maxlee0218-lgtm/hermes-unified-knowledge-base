#!/usr/bin/env python3
"""测试 Scrapling 访问政府证照查询网站"""

from scrapling.fetchers import Fetcher, FetcherSession

def test_mem_gov():
    """测试特种作业证查询网站"""
    print("=== 测试特种作业证网站 (cx.mem.gov.cn) ===")
    
    # 特种作业证 API 端点
    url = "https://cx.mem.gov.cn/prod-api/certsearch/code"
    
    with FetcherSession(impersonate='chrome') as session:
        # 先拿验证码
        resp = session.get(url)
        print(f"验证码接口状态: {resp.status}")
        
        if resp.status == 200:
            # 尝试直接访问查询页面
            page = session.get("https://cx.mem.gov.cn/")
            print(f"主页面状态: {page.status}")
            print(f"页面标题: {page.title}")
            # 看看能不能找到验证码图片
            imgs = page.css('img')
            print(f"图片数量: {len(imgs)}")
            return True
    return False


def test_cqs_cn():
    """测试焊工证查询网站"""
    print("\n=== 测试焊工证网站 (cnse.e-cqs.cn) ===")
    
    url = "https://cnse.e-cqs.cn/info-pub/pubh5"
    
    with FetcherSession(impersonate='chrome') as session:
        resp = session.get(url)
        print(f"焊工证页面状态: {resp.status}")
        if resp.status == 200:
            print(f"页面标题: {resp.title}")
            # 查找表单字段
            inputs = resp.css('input')
            print(f"输入框数量: {len(inputs)}")
            for inp in inputs[:5]:
                name = inp.attrs.get('name', '')
                placeholder = inp.attrs.get('placeholder', '')
                print(f"  - name={name}, placeholder={placeholder}")
            return True
    return False


if __name__ == "__main__":
    print("Scrapling HTTP Fetcher 测试\n")
    print("无需浏览器！纯 HTTP 请求，伪装 Chrome TLS 指纹")
    print("="*50)
    
    ok1 = test_mem_gov()
    ok2 = test_cqs_cn()
    
    print("\n" + "="*50)
    print(f"特种作业证: {'✅ 可访问' if ok1 else '❌ 失败'}")
    print(f"焊工证: {'✅ 可访问' if ok2 else '❌ 失败'}")
