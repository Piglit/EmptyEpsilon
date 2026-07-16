rm luacov.stats.out
echo "================================================================================"
lua -lluacov ./test_comms_abomination.lua && luacov && grep -e "$**0" luacov.report.out
tail -n 10 luacov.report.out

# this runs best with:
#ls *.lua | entr ./test.sh 
