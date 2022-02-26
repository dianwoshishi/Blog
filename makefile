all:
	make nodeppt
	hexo g 
	hexo d 

nodeppt:
	$(MAKE) -C source/slideshare/

test:
	make nodeppt
	hexo g
	hexo s

deploy:
	make nodeppt
	hexo g 
	hexo d
	