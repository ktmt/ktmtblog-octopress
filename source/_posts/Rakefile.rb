desc "push to octopress also"
task :push_octopress do
	puts "pushing to octopress repo"
	system "git checkout master"
	system "git pull octopress master"
	system "git add ."
	system "git commit -m 
