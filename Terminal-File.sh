#!/bin/bash
# Terminal-File.sh
# —————————————————————————————————————————————————————————
# v1.2-3
# 版本号小规范介绍: v1.1-56中的1.1代表主次版本号(这个是之前的版本号现在被拿了做示例了)
# 小更新给次版本号加1大更新给主版本号加1
# -50后面的50是代表修订次数每一次有bug或者其他问题修改时加一
# 每一次的主版本号或者次版本号更新后修订号就要清空以来开启新的循环
# 重大错误: 4 # 数字几代表出来了几次重大错误
# bug {
# 126行语法错误但是找不到是哪里的语法错误这很难评(已修复)
# 暂无bug
# }
# —————————————————————————————————————————————————————————
# 介绍: 一个简易的文件管理器
# 功能1: 进入其他目录
# 功能2: 删除文件/文件夹
# 功能3: 列出当前目录的内容
# 功能4: 查看回收站
# 功能5: 设置
# —————————————————————————————————————————————————————————
# 分割线上面为介绍或其他
# —————————————————————————————————————————————————————————
# 依赖bash, zsh(zsh可以不需要但是推荐), find 但是通常来讲基本上设备都有这两个所以一般不需要安装
# —————————————————————————————————————————————————————————
# 初始化
Version=v1.2-3
echo "正在初始化中……"
sleep 1
echo "请稍后……"

# 创建必要的目录和文件
mkdir -p /var/mobile/Terminal-File/Terminal-File # 创建Terminal-File自己的专属目录
mkdir -p /var/mobile/Terminal-File/.Trash # 创建回收站
mkdir -p /var/mobile/Terminal-File/.config # 创建配置目录
touch /var/mobile/Terminal-File/.Terminal-File.file
touch /var/mobile/Terminal-File/.Trash/.Terminal-File.file

# 默认配置
if [ ! -f /var/mobile/Terminal-File/.config/default_dirs ]; then
    cat > /var/mobile/Terminal-File/.config/default_dirs << EOF
/var/mobile/Documents
/var/mobile/Downloads
/var/root/Documents
/var/root/Downloads
/var/tmp
EOF
    echo "/var/mobile/Documents" > /var/mobile/Terminal-File/.config/default_dir
fi

# 读取默认目录
default_dir=$(cat /var/mobile/Terminal-File/.config/default_dir)

# cd到默认目录中
cd "$default_dir"

# 函数：显示更新日志
show_changelog() {
    clear
    echo "Terminal-File 更新日志"
    echo "======================"
    echo "Version (当前版本)" # 每一次更新时这里不需要动
    echo "- 修复一些bug"
    echo ""
    echo "v1.0-50"
    echo "- 不在使用Terminal-File做为回收站而是使用Terminal-File/.Trash"
    echo "- 添加了设置菜单"
    echo "- 新添加了默认目录管理更改功能 现在可以自定义或者选择其他目录作为默认目录"
    echo ""
    echo "v1.0-49"
    echo "- 修复了rm -rv回收站的问题"
    echo "- 优化了部分代码"
    read -p "按回车键返回..."
}

# 函数：显示开发日志
show_devlog() {
    clear
    echo "Terminal-File 开发日志"
    echo "======================"
    echo "- 开发时间: 2025年9月2日"
    echo "- 开发者AD ,开发者学历初二 ,所属团队SCT"
    echo "- 当初是随便写写的一个玩具但是没有想到现在变成自行车轮子了"
    echo "- 说实话基础文件管理功能很容易实现但是其他私有功能就比较难了"
    echo "- 在添加'设置'这个功能的时候遇到了JSON和jq的挑战 现在改用了函数来实现"
    echo "- 修复了一些语法的bug"
    read -p "按回车键返回..."
}

# 函数：选择默认目录
select_default_dir() {
    clear
    echo "选择默认目录"
    echo "============"
    echo "当前默认目录: $default_dir"
    echo ""
    
    # 显示可用的默认目录
    count=1
    while IFS= read -r dir; do
        echo "$count. $dir"
        ((count++))
    done < /var/mobile/Terminal-File/.config/default_dirs
    
    echo "0. 返回"
    read -p "请选择: " choice
    
    if [ "$choice" -eq 0 ]; then
        return
    fi
    
    # 获取选择的目录
    selected_dir=$(sed -n "${choice}p" /var/mobile/Terminal-File/.config/default_dirs 2>/dev/null)
    
    if [ -n "$selected_dir" ] && [ -d "$selected_dir" ]; then
        echo "$selected_dir" > /var/mobile/Terminal-File/.config/default_dir
        default_dir="$selected_dir"
        cd "$default_dir"
        echo "默认目录已更改为: $default_dir"
    else
        echo "无效的选择或目录不存在!"
    fi
    
    read -p "按回车键继续..."
}

while true; do
    clear
    echo "创作者: AD ,版本号: $Version"
    echo "当前时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "当前目录: $(pwd)"
    echo "1. 进入其他目录"
    echo "2. 删除一个文件/文件夹"
    echo "3. 列出当前目录的文件夹/文件"
    echo "4. 回收站"
    echo "5. 设置"
    echo "0. 退出"
    read -p "请选择(1-5): " choice

    case $choice in
        1)
            echo "当前目录: $(pwd)"
            echo "请输入需要进入的目录路径"
            read -p "请输入: " catalogue
            if [ -d "$catalogue" ]; then
                cd "$catalogue"
                echo "执行成功! 您当前在 $(pwd) 目录中"
            else
                echo "错误: 目录 '$catalogue' 不存在!"
            fi
            read -p "按回车键继续..."
            ;;
        2)
            echo "当前目录: $(pwd)"
            echo "需要删除的文件/文件夹是当前目录的还是其他目录的?"
            read -n 1 -p "当前目录? (y/n): " rm_choice
            echo
            
            if [[ "$rm_choice" =~ [yY] ]]; then
                echo "当前目录的内容:"
                ls -la
                read -p "请输入需要删除的文件/文件夹名称: " target_file
                if [ -e "$target_file" ]; then
                    echo "正在移动 '$target_file' 到回收站..."
                    mv "$target_file" /var/mobile/Terminal-File/.Trash/
                    echo "操作成功!"
                else
                    echo "错误: 文件/文件夹 '$target_file' 不存在!"
                fi
            else
                read -p "请输入完整路径: " full_path
                if [ -e "$full_path" ]; then
                    filename=$(basename "$full_path")
                    echo "正在移动 '$filename' 到回收站..."
                    mv "$full_path" /var/mobile/Terminal-File/.Trash/
                    echo "操作成功!"
                else
                    echo "错误: 路径 '$full_path' 不存在!"
                fi
            fi
            read -p "按回车键继续..."
            ;;
        3)
            echo "当前目录: $(pwd)"
            echo "目录内容:"
            ls -la
            read -p "按回车键继续..."
            ;;
        4)
            echo "回收站内容:"
            ls -la /var/mobile/Terminal-File/.Trash/
            echo
            read -p "清空回收站还是返回? (Empty/Return): " option
            
            if [[ "$option" =~ [Ee]mpty ]]; then
                echo "正在清空回收站..."
                # 删除所有文件但保留标记文件
                find /var/mobile/Terminal-File/.Trash/ -mindepth 1 ! -name ".Terminal-File.file" -exec rm -rf {} +
                echo "回收站已清空!"
            else
                echo "返回主菜单..."
            fi
            sleep 1
            ;;
        5)
            while true; do
                clear
                echo "当前时间: $(date '+%Y-%m-%d %H:%M:%S')"
                echo "这里是Terminal-File设置"
                echo "======================"
                echo "当前默认目录: $default_dir"
                echo ""
                echo "1. 切换默认目录"
                echo "2. Terminal-File的更新日志"
                echo "3. 开发日志"
                echo "0. 返回主菜单"
                read -p "请选择(1-3): " Terminal_File_Set

                case $Terminal_File_Set in
                    1)
                        select_default_dir
                        ;;
                    2)
                        show_changelog
                        ;;
                    3)
                        show_devlog
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo "无效选项，请重新选择!"
                        sleep 1
                        ;;
                esac
            done
            ;;
        0)
            echo "感谢使用，再见! 欢迎下次再来"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择!"
            sleep 1
            ;;
    esac
done