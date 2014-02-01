source "$rvm_path/scripts/rvm"

rvm use 1.8.7-p370 --install

: create/use/rename/delete
rvm gemset create test_gemset            # status=0 ; match=/gemset created/
rvm gemset use test_gemset               # status=0 ; match=/Using /
rvm current                              # match=/test_gemset/
rvm gemset list                          # match=/test_gemset/; match!=/other_gems/
rvm gemset rename test_gemset other_gems # status=0
rvm current                              # match=/other_gems/
rvm gemset list                          # match!=/test_gemset/; match=/other_gems/
rvm --force gemset delete other_gems     # status=0
rvm gemset list                          # match!=/test_gemset/
rvm gemset create test_gemset            # status=0 ; match=/gemset created/
rvm gemset use test_gemset               # status=0 ; match=/Using /
rvm current                              # match=/test_gemset/
rvm --force gemset delete test_gemset    # status=0
rvm current                              # match=/^ruby-1.8.7-p370$/
rvm gemset list                          # match!=/test_gemset/

: rvm ... do
rvm 1.8.7-p370 do rvm gemset create test_gemset            # status=0 ; match=/gemset created/
rvm 1.8.7-p370 do rvm gemset list                          # match=/test_gemset/; match!=/other_gems/
rvm 1.8.7-p370 do rvm --force gemset delete test_gemset    # status=0

: rvm ... do new rvm_gemsets_path
rvm use 1.8.7-p370
true TMPDIR:${TMPDIR:=/tmp}:
d=$TMPDIR/test-rvm_gemsets_path
mkdir -p $d
echo rvm_gems_path=$d  >> ~/.rvmrc
echo rvm_create_flag=1 >> ~/.rvmrc
rvm gemset create test_gemset            # status=0 ; match=/gemset created/; match=/rvm_gemsets_path/
rvm gemset list                          # match=/test_gemset/; match!=/other_gems/; match=/rvm_gemsets_path/
rvm --force gemset delete test_gemset    # status=0
rvm 1.8.7-p370 do rvm gemset create test_gemset            # status=0 ; match=/gemset created/; match=/rvm_gemsets_path/
rvm 1.8.7-p370 do rvm gemset list                          # match=/test_gemset/; match!=/other_gems/; match=/rvm_gemsets_path/
rvm 1.8.7-p370 do rvm --force gemset delete test_gemset    # status=0
sed -i'' -e "/rvm_gems_path=${d//\//\/}/ d" -e "/rvm_create_flag=1/ d" ~/.rvmrc
rm -rf $d

: export/import/use
rvm gemset create test_gemset
rvm gemset use test_gemset               # status=0 ; match=/Using /
rvm gemdir                               # match=/@test_gemset$/
gem install haml
rvm gemset export haml.gems              # status=0; match=/Exporting /
[[ -f haml.gems ]]                       # status=0
rvm --force gemset empty                 # status=0
gem list                                 # match!=/haml/
rvm gemset import haml.gems              # status=0; match=/Installing /
rm haml.gems
gem list                                 # match=/haml/
echo yes | rvm gemset delete test_gemset # status=0
rvm gemset list                          # match!=/test_gemset/

: use/create
ls $rvm_path/wrappers/*test_gemset*      # status!=0
ls $rvm_path/gems/*test_gemset*          # status!=0
rvm gemset list                          # match!=/test_gemset/
rvm --force gemset delete test_gemset    # status=0
rvm gemset use test_gemset --create      # status=0 ; match=/Using /
ls $rvm_path/wrappers/*test_gemset*      # status=0
ls $rvm_path/gems/*test_gemset*          # status=0
rvm gemset list                          # match=/test_gemset/
rvm --force gemset delete test_gemset    # status=0

: cleanup
rm -rf $rvm_path/log/*
ls $rvm_path/*/*test_gemset*             # status!=0
rvm gemset list                          # match!=/test_gemset/

: use
rvm --force gemset delete unknown_gemset # status=0
rvm gemset use unknown_gemset            # status!=0; match=/does not exist/
rvm current                              # match!=/unknown_gemset/

: default
rvm gemset list                          # match=/default/
