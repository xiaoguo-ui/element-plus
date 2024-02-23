#! /bin/bash
# 设置一个环境变量。
# 将脚本执行时的第一个参数值赋给 NAME 变量，并将 NAME 导出为全局环境变量。
export NAME=$1
# 将当前脚本所在目录的父目录下的 packages 目录的完整路径赋给 FILE_PATH 变量，并将 FILE_PATH 导出为全局环境变量。

# $(...) 是命令替换，它会执行括号内的命令，并将结果替换到原位置。
# ${BASH_SOURCE[0]} 是当前脚本的文件名。
# $(dirname "${BASH_SOURCE[0]}") 是获取当前脚本的目录名。
# && pwd 如果上一个 cd 命令执行成功，那么执行 pwd 命令，pwd 命令会打印当前工作目录的完整路径。
export FILE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/../packages" && pwd)

# 设置 re 变量的值为一个匹配一个或多个空白字符的正则表达式。这个正则表达式可以用于在文本中查找连续的空白字符。
# [[:space:]] 是 POSIX 字符类，代表任何空白字符，包括空格、制表符、换行符等。
re="[[:space:]]+"

# if [ "$#" -ne 1 ] 检查传入脚本的参数数量是否不等于 1。$# 是一个特殊变量，代表传入脚本的参数数量。 -ne 是一个比较运算符，表示 "不等于"。
# [[ $NAME =~ $re ]] 这部分检查变量 NAME 的值是否匹配正则表达式 re。=~ 是一个正则表达式匹配运算符。
# [ "$NAME" == "" ] 检查变量 NAME 的值是否为空。
if [ "$#" -ne 1 ] || [[ $NAME =~ $re ]] || [ "$NAME" == "" ]; then
  # 输出错误信息到标准错误输出。
  echo "Usage: yarn gc \${name} with no space"
  # 退出脚本
  exit 1
# fi 是 if 语句的结束标记。
fi

DIRNAME="$FILE_PATH/$NAME"

# if [ -d "$DIRNAME" ]; 检查 $DIRNAME 是否是一个目录。
if [ -d "$DIRNAME" ]; then
  echo "$NAME component already exists, please change it"
  exit 1
fi

NORMALIZED_NAME=""
# 使用 sed 命令对 $NAME 进行处理，将 _ 或 - 后面的小写字母或字符串的首字母前面添加一个空格，
# 然后将处理后的字符串分割成多个部分，每个部分用 i 表示，
# C=$(echo "${i:0:1}" | tr "[:lower:]" "[:upper:]") 取 i 的第一个字符，然后使用 tr 命令将其转换为大写，赋值给 C。
# NORMALIZED_NAME="$NORMALIZED_NAME${C}${i:1}" 将 C 和 i 的剩余部分（即从第二个字符开始的部分）拼接到 NORMALIZED_NAME 的后面。
# done：这一行标记 for 循环的结束。

# 将 $NAME 中的每个单词的首字母转换为大写，其他字母保持不变，然后将处理后的单词拼接起来，赋值给 NORMALIZED_NAME。
# 例如，如果 $NAME 的值为 hello_world，那么 NORMALIZED_NAME 的值将会是 HelloWorld。
for i in $(echo $NAME | sed 's/[_|-]\([a-z]\)/\ \1/;s/^\([a-z]\)/\ \1/'); do
  C=$(echo "${i:0:1}" | tr "[:lower:]" "[:upper:]")
  NORMALIZED_NAME="$NORMALIZED_NAME${C}${i:1}"
done
NAME=$NORMALIZED_NAME

TEMPLATE_INDEX_VUE="<template>\n
  <div>\n
  </div>\n
</template>\n
<script lang='ts'>\n
export default {\n
  NAME: 'El${NAME}',\n
    props: {\n
    },\n
    setup(props,ctx) { }\n
  };\n
</script>\n
<style>\n
</style>\n
"

TEMPLATE_INDEX_TS="\n
import { App } from 'vue'\n
import ${NAME} from './src/index.vue'\n
export default (app: App) => {\n
  app.component(${NAME}.name, ${NAME})\n
}
"
TEMPLATE_PKG_JSON="\n
{\n
  \"name\": \"eleplus-${NAME}\",\n
  \"description\": \"\",\n
  \"version\": \"0.1.0\",\n
  \"main\": \"./index.ts\",\n
  \"license\": \"MIT\",\n
  \"dependencies\": {}\n
}\n
"

mkdir -p "$DIRNAME"
mkdir -p "$DIRNAME/src"
echo $TEMPLATE_INDEX_VUE >>"$DIRNAME/src/index.vue"
echo $TEMPLATE_INDEX_TS >>"$DIRNAME/index.ts"
echo $TEMPLATE_PKG_JSON >>"$DIRNAME/package.json"
