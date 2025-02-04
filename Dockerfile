# 使用官方轻量级 Alpine 作为构建基础镜像
FROM golang:1.21-alpine AS builder

# 安装构建依赖
RUN apk --no-cache add build-base

# 设置工作目录
WORKDIR /build

# 复制源代码
COPY main.go .

# 使用缓存加速 Go 依赖下载（需要 BuildKit 支持）
RUN --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o api_transformer main.go

# 生产环境镜像，使用 `scratch` 以最小化大小
FROM scratch AS prod

# 复制证书和二进制文件
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/api_transformer /api_transformer

# 设置暴露端口
EXPOSE 8080

# 运行二进制文件
CMD ["/api_transformer"]
