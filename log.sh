#!/bin/sh
# --------------------------------------------------------------------
# author:   hoojo
# email:    hoojo_@126.com
# github:   https://github.com/hooj0
# create date: 2018-08-25
# copyright by hoojo @ 2018
# --------------------------------------------------------------------

# @changelog Log shell script tools

function log() {
	# 字颜色：30—–37
	# 字背景颜色范围：40—–47
	case "$1" in
		"red")
			echo -e "\033[31;1m$2\033[0m" # 红色字
		;; 
		"yellow")
			echo -e "\033[33;1m$2\033[0m" # 黄色字
		;; 
		"green")
			echo -e "\033[32;1m$2\033[0m" # 绿色字
		;; 
		"blue")
			echo -e "\033[34;1m$2\033[0m" # 蓝色字
		;; 
		"purple")
			echo -e "\033[35;1m$2\033[0m" # 紫色字
		;; 
		"sky_blue")
			echo -e "\033[36;1m$2\033[0m" # 天蓝字
		;; 
		"white")
			echo -e "\033[37;1m$2\033[0m" # 白色字
		;; 
		"_black")
			echo -e "\033[40;37;1m $2 \033[0m" # 黑底白字
		;; 
		"_red")
			echo -e "\033[41;30;1m $2 \033[0m" # 红底黑字
		;;
		"_green")
			echo -e "\033[32;5;1m$2\033[0m" # 绿色字
		;;
		"_blue")
			echo -e "\033[34;2;1m $2\033[0m" # 蓝色字
		;;	
		"done")
			echo -e "\033[31;1m$2\033[0m...... \033[32;1mDone!\033[0m" # 绿色字
			printf "\n\n"
		;;	
		*)
			echo "$2"
		;;
	esac
}