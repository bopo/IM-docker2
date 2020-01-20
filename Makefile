# Makefile six
CWD=`pwd`

.PHONY: docs clean start build setup

help:
	@echo "setup    - 安装基本依赖(初始化)"
	@echo "fetch    - 更新版本库最新代码"
	@echo "clean    - 清理编译垃圾数据"
	@echo "build    - 编译所需镜像"
	@echo "start    - 开始项目容器"
	@echo "stop     - 停止项目容器"
	@echo "destry   - 销毁项目容器"
	@echo "doctor   - 所有容器自检"
	@echo "restart  - 重启项目容器"

doctor:
	docker-compose run --rm imserv doctor

destry:
	docker-compose rm -a -f

distclean: clean
	rm -rf build
	rm -rf compose/imserv/target

clean: clean-pyc

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

fetch:
	test -d build/imserv || git clone --depth=1 https://github.com/bopo/im.git build/imserv
	test -d volumes/imserv/etc || mkdir -p volumes/imserv/etc && cp -R build/imserv/config volumes/imserv/etc

build: fetch
	cp scripts/imserv/* build/imserv
	cd build/imserv && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on make build && cd $(CWD)
	cp -R build/imserv/target compose/imserv
	docker build ./compose/imserv -t imserv:standard

stop:
	docker-compose stop

start: 
	docker-compose start

setup: build
	docker-compose up -d

restart: 
	docker-compose restart

# DO NOT DELETE
