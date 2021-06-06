# The MIT License (MIT)
#
# Copyright (c) 2021 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

.SHELLFLAGS = -e -c

.ONESHELL:

HOME=dataset

all: $(HOME)/repositories.csv cleanup clone filter

# Delete everything, in order to start from scratch.
clean:
	rm -rf $(HOME)

# Get the list of repos from GitHub and then create directories
# for them. Each dir will be empty.
$(HOME)/repositories.csv:
	ruby discover-repos.rb --total=4 --page=4 "--path=$(HOME)/repositories.csv"
	cat "$(HOME)/repositories.csv"

# Delete directories that don't exist in the list of
# required repositories.
cleanup: $(HOME)/repositories.csv $(HOME)/github
	for d in $$(find $(HOME)/github -depth 2 -print); do
		repo=$$(echo $${d} | gsed "s|$(HOME)/github/||")
		if grep -Fxq "$${repo}" $(HOME)/repositories.csv; then
			echo "Directory $${d} is here and is needed (for $${repo})"
		else
			rm -rf "$${d}"
			echo "Directory $${d} is obsolete and was deleted (for $${repo})"
		fi
	done
	for d in $$(find $(HOME)/github -depth 1 -print); do
		if [ "$$(ls $${d} | wc -l)" == '0' ]; then
			rm -rf "$${d}"
			echo "Directory $${d} is empty and was deleted"
		fi
	done

# Make directories for further cloning into them.
cleanup: $(HOME)/repositories.csv $(HOME)/github
	for d in $$(find $(HOME)/github -depth 2 -print); do
		repo=$$(echo $${d} | gsed "s|$(HOME)/github/||")
		if grep -Fxq "$${repo}" $(HOME)/repositories.csv; then
			echo "Directory $${d} is here and is needed (for $${repo})"
		else
			rm -rf "$${d}"
			echo "Directory $${d} is obsolete and was deleted (for $${repo})"
		fi
	done
	for d in $$(find $(HOME)/github -depth 1 -print); do
		if [ "$$(ls $${d} | wc -l)" == '0' ]; then
			rm -rf "$${d}"
			echo "Directory $${d} is empty and was deleted"
		fi
	done

# Clone all necessary repositories.
# Don't touch those that already have any files in the dirs.
clone: $(HOME)/repositories.csv $(HOME)/github
	while IFS= read -r r; do
	  	if [ -e "$(HOME)/github/$${r}/.git" ]; then
	    	echo "$${r}: Git repo is already here"
	  	else
	    	echo "$${r}: trying to clone it..."
	    	git clone "https://github.com/$${r}" "$(HOME)/github/$${r}"
	  	fi
	done < "$(HOME)/repositories.csv"

filter: $(HOME)/github
	mkdir -p $(HOME)/temp
	mkdir -p $(HOME)/summary
	for f in $$(ls filters/); do
		"filters/$${f}" $(HOME)/github "$(HOME)/summary/$${f}.tex" $(HOME)/temp
		echo "Filter $${f} published its results to $(HOME)/summary/$${f}.tex"
	done
	for f in $$(ls "$(HOME)/summary/"); do
		echo "$${f}:"
		cat "$(HOME)/summary/$${f}"
		echo ""
	done

$(HOME)/github:
	mkdir -p $(HOME)/github

