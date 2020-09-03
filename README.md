fork [https://github.com/CCChieh/IBMYes](https://github.com/CCChieh/IBMYes)  


# 更新内容:
* `Secrets` 加入 `V2_ID`, `V2_PATH`, `ALTER_ID`,  
  对应`vmess id`, `ws path`, `alterId`
* 每周自动更新`v2ray`后重新`push`


# 配置流程

### 配置IBM Cloud Fonudray
* 注册并登录[https://cloud.ibm.com/](https://cloud.ibm.com/)
* 点击右侧 创建资源
* 点击`Cloud Foundray`
* 创建公共应用程序
* 填写相关信息: 区域达拉斯(免费). 内存最高256M. 应用名称. 配置资源选Go
* 应用程序域名 就是 应用名称+域, 比如: `ibmyes.us-south.cf.appdomain.cloud`
* 点击右侧 创建

### 配置 Cloudflare 高速节点中转
这部分不配置也可以直接连 应用程序域名 使用, 就是有点慢.
* 注册并登录[https://www.cloudflare.com/](https://www.cloudflare.com/)
* 点击 Workers
* 点击 创建Worker
* 在脚本位置加入下面这段, `url.hostname`修改为对应的 应用程序域名.
```
addEventListener(
  "fetch",event => {
    let url=new URL(event.request.url);
    url.hostname="ibmyes.us-south.cf.appdomain.cloud";
    let request=new Request(url,event.request);
    event.respondWith(
      fetch(request)
    )
  }
)
```
* 点击保存并部署, 这里会给一个网址(比如`cloudflare_workers.dev`), 这个就是 v2ray 客户端要连的地址.

### 利用Github Actions 自动部署 IBM Cloud Fonudray
* 返回 github, 到本项目 [https://github.com/fcying/IBMYes](https://github.com/fcying/IBMYes)
* 点击右上角 Fork 到自己的github下, 点击 Settings
* 点击 `Secrets` 建立以下几个`secret`:  
  `IBM_ACCOUNT`:　　　IBM Cloud的登录邮箱和密码, 一行邮箱, 一行密码.  
  `IBM_APP_NAME`:　　应用的名称.  
  `RESOURSE_ID`:　　　资源组ID, 只有一个应用可以不用. 可以在IBM Cloud的管理->账户->资源组里面找到.  
  `V2_ID`:　　　　　　vmess id  
  `V2_PATH`:　　　　　ws path  
  `ALTER_ID`:　　　　alterId  
* 修改项目`README.md`(打开文件, 右上角有个 `Edit this file`的图标), 随便加个空格, 点 `Commit changes`.
* 点击项目 Actions, 可以看到有个`IBM Cloud Deploy` 正在工作了, 每周会自动部署一次(IBM 10天不用会停).

### Clash 客户端设置
这里的客户端用的是`Clash`, 下面为对应的`vmess`部分设置.修改其中的`server`,`uuid`,`path`就好了.
```
  - name: "IBM"
    type: vmess
    server: cloudflare_workers.dev
    port: 443
    uuid: V2_ID
    alterId: ALTER_ID
    cipher: none
    udp: true
    tls: true
    network: ws
    ws-path: /V2_PATH
```
    server: cloudflare.com
`server` 可以使用 `cloudflare.com`或者别的CF的比较快的IP,对应的加一个伪装设置就行
```
    server: cloudflare.com
    ws-headers:
      Host: cloudflare_workers.dev
```
