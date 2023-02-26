#!/bin/python3.11
import sys
import pandas as pd


def comb(FPATH: str, N: str, T: str, D: str):
    # FPATH：文件路径，N:节点文件，T:温度文件，D：合并文件

    tmpN = pd.read_csv(
        "{0}/{1}.csv".format(FPATH, N),
        sep='\t', header=None)
    tmpT = pd.read_csv(
        "{0}/{1}.csv".format(FPATH, T),
        sep='\t', header=None)
    data = tmpN.merge(tmpT, how='left', on=0)
    data.to_csv(
        "{0}/{1}.csv".format(FPATH, D),
        sep='\t', header=None, index=None)


if __name__ == '__main__':
    print("\t\t<python-comb> running in shell ......")
    comb(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
    print("\t\t<python-comb> finished! </python>")
else:
    print("\t\t<python-merge> Please run in file! </python>")
