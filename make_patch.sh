usage()
{
echo "Usage : `basename $0` [opt] [commit id 1] [commit id 2]"
echo "if [commit id 1], [commit id 2] is null ,get HEAD commit diff patch"
echo "if [commit id 2] is null , get the modify of [commit id 1] with previous commit id "
echo "support OPT:"
echo "-h or \? show the Usage"
echo "-a archive the patch"
echo "-d do not generate the .diff file"
exit 1
}
check_err()
{
	error_str1="fatal: Not a valid object name"
	error_str2="fatal: pathspec"
	error_str3="fatal: Not a git repository"
	[[ $1 =~ $error_str1 ]] && echo "the commit id is wrong , please input the correct commit id" && exit 1 
	[[ $1 =~ $error_str2 || $1 =~ $error_str3 ]] && echo "the git root path is wrong , please cd to the writh path, like /prj_folder/kernel dir" && exit 1
}
PATCH_FOLDER=""
create_patch_dir()
{
	curDateTime=$(date "+%Y-%m-%d_%H_%M_%S")
	PATCH_FOLDER=.//$curDateTime
	mkdir "$PATCH_FOLDER"
}
ARCHIVE=n
DIFF=y
CID_NUM=$#
SHIFT_NUM=0
while getopts :adh opt;do
	case $opt in
	 a)
		ARCHIVE=y
		((CID_NUM--))
		((SHIFT_NUM++))
		;;	
	 d)
		DIFF=n		
		((CID_NUM--))
		((SHIFT_NUM++))
		;;
	 h)
		usage
		;;
         ?)
		usage
		;;
	esac
done
#if [ ! -d ~/new_old_patch ];then
#mkdir ~/new_old_patch
#fi
#echo $curDateTime
#to create the patch dir
create_patch_dir
if [ $SHIFT_NUM -ne 0 ] ; then
shift $SHIFT_NUM
fi
if [ $CID_NUM == 0 ] ; then 
	echo "Generating HEAD commit diff"
	archive_files=$(git diff --diff-filter=ACMR --name-only HEAD^)
	if [[ -z $archive_files ]]
	then 	
	echo "The HEAD maybe a tag, there is no diff files, please try another CID"
	exit 1
	fi
	status=$(git archive -o ./new.zip HEAD $archive_files 2>&1)
	check_err "$status"	
	archive_files=$(git diff --diff-filter=ACMR --name-only HEAD HEAD^)
	git archive -o ./old.zip HEAD^ $archive_files
	if [ $DIFF == "y" ] ; then
		git diff HEAD^ >> $PATCH_FOLDER/$curDateTime.diff
	fi 
elif [ $CID_NUM == 1 ] ; then
	echo "Generating the diff of commit id $1"
	archive_files=$(git diff --diff-filter=ACMR --name-only $1^ $1)
	if [[ -z $archive_files ]]
	then 	
	echo "The CID maybe a tag, there is no diff files, please try another CID"
	exit 1
	fi
	status=$(git archive -o ./new.zip $1 $archive_files 2>&1)
	check_err "$status"	
	archive_files=$(git diff --diff-filter=ACMR --name-only $1 $1^)	
	git archive -o ./old.zip $1^ $archive_files 
	if [ $DIFF == "y" ] ; then
		git diff $1^ $1 >> $PATCH_FOLDER/$curDateTime.diff
	fi 
elif [ $CID_NUM == 2 ] ; then
	echo "Generating the diff of commit id $1 $2"
	archive_files=$(git diff --diff-filter=ACMR --name-only $2 $1)
	if [[ -z $archive_files ]]
	then 	
	echo "One CID maybe a tag, there is no diff files, please try another CID"
	exit 1
	fi
	status=$(git archive -o ./new.zip $1 $archive_files 2>&1)
	check_err "$status"
	archive_files=$(git diff --diff-filter=ACMR --name-only $1 $2)
	status=$(git archive -o ./old.zip $2 $archive_files 2>&1)
	check_err "$status"
	if [ $DIFF == "y" ] ; then
		git diff $2 $1 >> $PATCH_FOLDER/$curDateTime.diff
	fi 
fi
#cd ~/new_old_patch
#echo $PWD
unzip -o -d ./$curDateTime/new/ new.zip
unzip -o -d ./$curDateTime/old/ old.zip
rm new.zip old.zip
echo $ARCHIVE 
if [ $ARCHIVE == "y" ] ; then
	tar -czvf $curDateTime.tar $curDateTime
fi
