# 自动化工具

## PPT生成工具使用nodeppt



具体格式见nodeppt官方仓库https://github.com/ksky521/nodeppt



因为不能集成在hexo中，所以使用nodeppt先生成ppt，在将其拷贝至相应目录



```shell
#！/bin/bash
src_md=$1
pub_dir='/slideshare/slides'
dst_dir='../public'$pub_dir
mkdir -p  $dst_dir

echo '# usage: sh run.sh your-md-file-name.md'

# 从当前目录，我的是project/nodeppt,拷贝到hexo目录的
/usr/bin/nodeppt build $src_md -d $dst_dir
cd $dst_dir;





index_name='../../../source/slideshare/index.md'
echo '---' > $index_name
echo 'title: 幻灯片展示' > $index_name
echo '---' > $index_name

ls -l | grep ^- | awk '{printf(" - [%s](/slideshare/slides/%s) \n", $9,$9) }' > $index_name

echo "/source/slideshare/index.md内容为："
cat $index_name


# usage: sh run.sh your-md-file-name.md
```

