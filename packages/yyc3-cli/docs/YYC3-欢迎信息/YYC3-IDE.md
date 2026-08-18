---
@file: YYC3-IDE.md
@description: YYC³-CLI YYC3-IDE.md
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [文档],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

# YYC3 欢迎信息

show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
  ██╗   ██╗██╗   ██╗ ██████╗██████╗     ██╗  ██████╗  ███████╗
  ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗    ██║  ██╔══██╗ ██╔════╝
   ╚████╔╝  ╚████╔╝ ██║      █████╔╝    ██║  ██║  ██║ █████╗  
    ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗    ██║  ██║  ██║ ██╔══╝  
     ██║      ██║   ╚██████╗██████╔╝    ██║  ██████╔╝ ███████╗
     ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚═╝  ╚═════╝  ╚══════╝

    言语云³ 开发者工具包
    YanYu Intelligence Cloud³ Developer Kit
    =====================================
EOF
    echo -e "${NC}"
    echo "🚀 快速初始化 YYC³ 开发环境"
    echo "📅 初始化时间: $(date)"
    echo ""
}

show_welcome
