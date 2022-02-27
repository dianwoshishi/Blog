all:
	hexo clean
	make nodeppt
	hexo g 
	gulp
	hexo d 
source:
	source ~/.profile
nodeppt:
	$(MAKE) -C source/slideshare/

test:
	hexo g
	hexo s

deploy:
	hexo g 
	hexo d
	
