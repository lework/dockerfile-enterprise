# Dockerfile 中小型企业实战指南

这份指南面向开发和运维团队，覆盖从编写 Dockerfile 到构建、运行和发布镜像的流程。第一次接触 Docker 时，从本页的本地示例开始。已有项目时，直接找到对应技术栈的章节。需要共享代码、镜像和依赖时，再看团队服务的部署步骤。

## 本地跑通第一个镜像

在安装了 Docker Engine、Buildx 和 `curl` 7.71 或更新版本的机器上，用 Bash 运行下方命令。命令会在临时目录创建一个网页，用 Nginx 镜像提供访问，并把容器的 80 端口发布到本机 `127.0.0.1:18080`。基础镜像来自 [Amazon ECR Public](https://docs.aws.amazon.com/AmazonECR/latest/public/docker-pull-ecr-image.html)。

```bash
(
set -e
demo_dir=$(mktemp -d "${TMPDIR:-/tmp}/dockerfile-guide.XXXXXX")
cd "$demo_dir"

cat > Dockerfile <<'DOCKERFILE'
FROM public.ecr.aws/docker/library/nginx:stable-alpine
COPY index.html /usr/share/nginx/html/index.html
DOCKERFILE

printf '%s\n' 'Dockerfile guide OK' > index.html
docker buildx build --load -t dockerfile-guide:local .
demo_container=$(docker run --rm -d -p 127.0.0.1:18080:80 dockerfile-guide:local)
trap 'docker stop "$demo_container" >/dev/null' EXIT
curl --fail --silent --show-error --retry 5 --retry-all-errors http://127.0.0.1:18080/
)
```

终端显示 `Dockerfile guide OK` 后，说明容器已成功提供镜像中的页面。命令结束时会自动停止并移除示例容器。若构建时找不到 `index.html`，检查 `docker buildx build` 最后的 `.` 是否指向保存网页的目录。这个目录就是 Docker 的[构建上下文](https://docs.docker.com/build/concepts/context/)。

## 按技术栈构建应用

准备应用源码和章节所需的依赖文件，把章节内的应用构建示例保存为应用根目录下的 `Dockerfile.guide`。从应用根目录执行构建命令，让 `COPY` 能找到源码和配置。右栏链接指向本仓库维护的模板，便于对照。

| 技术栈 | 实践章节 | 仓库模板 |
| --- | --- | --- |
| Go | [35. Go 应用](<docs/35.实践篇-构建 Go 应用程序镜像.md>) | [Go](dockerfiles/app-build/golang) |
| PHP | [36. PHP 应用](<docs/36.实践篇-构建 PHP 应用程序镜像.md>) | [Yii](dockerfiles/app-build/yii) |
| Java | [37. Java 应用](<docs/37.实践篇-构建 Java 应用程序镜像.md>) | [Spring Boot](dockerfiles/app-build/springboot) |
| Python | [38. Python 应用](<docs/38.实践篇-构建 Python 应用程序镜像.md>) | [Django](dockerfiles/app-build/django) |
| Node.js | [39. Node.js 应用](<docs/39.实践篇-构建 Node.js 应用程序镜像.md>) | [Nuxt](dockerfiles/app-build/nuxt)、[Vue](dockerfiles/app-build/vue) |

- [34. OS 基础镜像](<docs/34.实践篇-构建标准化的 OS 基础镜像.md>)说明如何建立各语言镜像共用的底层。第 34–40 章保留 Debian 11 历史示例，其 LTS 已结束。新建环境请选择仍受支持的基础镜像。[Debian 公告](https://www.debian.org/News/2026/20260831)
- [40. 运维工具镜像](<docs/40.实践篇-构建运维工具.md>)覆盖 Ansible 和 Docker CLI。
- [dockerfiles/common](dockerfiles/common) 中，`os/` 存放基础系统镜像，`tools/` 存放编译工具镜像，`runtime/` 存放运行时镜像。已有应用所需镜像时，可直接开始构建应用。自行构建这些镜像时，先准备系统层，再按对应章节准备工具和运行时。只在本机验证可用 `docker buildx build --load`。运行 `build.sh` 会构建并推送镜像，执行前先核对目标仓库、项目和标签。
- 模板中的 `harbor.leops.local`、`nexus.leops.local` 等是示例环境地址。用自己的镜像和依赖仓库地址，并从实际执行构建的环境检查连通性。

## 搭建团队服务

1. [30. 准备环境](docs/30.实践篇-准备工作.md)。确认 Docker、Compose、域名和证书，再决定是否配置 Nginx 统一入口。
2. 按需准备 [GitLab 代码仓库](docs/31.实践篇-部署代码仓库.md)、[Harbor 镜像仓库](docs/32.实战篇-部署镜像仓库.md) 和 [依赖代理](docs/33.实践篇-部署代码依赖代理仓库.md)。团队已有这些服务时，使用现有地址和凭证。
3. [用 Jenkins 构建和推送](<docs/41.实践篇-使用 Jenkins 进行 CICD.md>)。从 GitLab 获取代码，交给执行节点构建镜像，再推送到 Harbor。先确认执行节点能访问 Docker Engine，两端仓库均可连通。

[docker-compose](docker-compose) 下按服务存放示例配置。Harbor 按部署章节在本机生成 Compose 和签名材料。运行服务前，检查端口、卷和凭证，并在对应目录运行 [`docker compose config -q`](https://docs.docker.com/reference/cli/docker/compose/config/) 验证配置。

## 概念、规范与进阶

- [0. 介绍](docs/0.介绍说明.md) · [10. Dockerfile 指令](docs/10.概念篇-认识Dockerfile.md) · [11. 常见构建方式](docs/11.概念篇-常见编译方式.md)
- [20. Dockerfile 编写规范](<docs/20.设计篇-Dockerfile 编写规范.md>) · [21. 镜像分层与管理](<docs/21.设计篇-Dockerfile 设计原则与镜像管理规范.md>)
- [50. 漏洞扫描与修复](<docs/50.进阶篇-扫描与修复 Docker 镜像漏洞.md>) · [54. 镜像拉取代理](<docs/54.进阶篇-Docker 镜像代理加速器配置指南.md>) · [55. Notation 签名](docs/55.进阶篇-使用Notation签名镜像.md)
- [51. Kaniko 构建历史示例](docs/51.进阶篇-kaniko编译镜像.md) · [52. 镜像生命周期管理](<docs/52.进阶篇-使用 Kaniko 在无 Docker Daemon 环境中构建镜像.md>) · [53. Kubernetes 规范](docs/53.进阶篇-Kubernetes集群相关规范.md)

交流方式见「乐运维」公众号，回复「加群」获取入口。
