# make a path between two commit ids
使用方法
1. cd到git仓库的根目录，如~/pike2/kernel$
2. 执行附件中的脚本make_patch.sh,会在用户目录下创建new_old_patch目录，并在此目录下生成以当前时间命名的patch文件夹

用法 `basename $0` [opt] [commit id 1] [commit id 2]

没有commit id输入的情况，生成当前HEAD修改的差分包
只输入commit id 1，生成commit id 1修改的差分包
输入commit id 1，commit id 2（确保commit id 1是较新的提交，commit id 2是较老的提交,写反了new old会刚好相反) 
，生成commit id 1，commit id 2之间的差分包(不包括commit id 2的修改）

opt选项如下：
-h or \? 帮助信息  ----------------> 
-a 打包  -------------> ~/make_patch.sh -a 将patch打包
-d 不生成.diff文件 ---------------> 此脚本默认生成.diff文件， -d选项不生成.diff文件
