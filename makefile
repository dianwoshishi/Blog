all:
	# $(MAKE) -C nodeppt/ 
	hexo g;
	hexo d;

test:
	hexo g
	hexo s

deploy:
	hexo g
	hexo d
	