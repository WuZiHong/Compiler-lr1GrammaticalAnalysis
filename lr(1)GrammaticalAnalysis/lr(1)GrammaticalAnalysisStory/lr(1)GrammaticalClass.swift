//
//  lr(1)GrammaticalClass.swift
//  lr(1)GrammaticalAnalysis
//
//  Created by 吴子鸿 on 16/10/18.
//  Copyright © 2016年 吴子鸿. All rights reserved.
//

import Foundation

struct tablecell{   //表格细胞
    var sgr:String;
    var num:Int;
}
struct DFAState{    //DFA状态
    var go:[String:Int]=[:];    //遇到哪个字符去数组哪一个状态
    var gram:[GrammarStruct]=[];    //文法集合
}
struct GrammarStruct {      //文法结构体
    var leftS:String=""     //产生式左部
    var rightS:String=""      //产生式的右部
    var p:Int=0     //当前标记点的位置
    var ahead:[String]=[];   //文法的展望字符的集合
}

class lr1GrammacticalClass {
    var GramList:[GrammarStruct]=[]   //文法们
    var NoendSymbol:[String]=[]     //非终结符的集合
    var EndSymbol:[String]=[]       //终结符集合
    var DFA:[DFAState]=[];          //DFA状态集合
    var table:[[String:tablecell]]=[];
    var atable:[[String]]=[];   //最终的分析表
    var returnStr:String=""     //返回的字符串
    init(GramList:[GrammarStruct],schar:String)
    {
        self.GramList=GramList;     //文法赋值
        var gram:GrammarStruct=GrammarStruct()
        gram.leftS="A"
        gram.rightS=schar
        gram.p=0
        self.GramList.insert(gram, atIndex: 0)
        //求非终结符集合
        for i in 0..<self.GramList.count
        {
            if NoendSymbol.indexOf(self.GramList[i].leftS) == nil
            { NoendSymbol.append(self.GramList[i].leftS)}
        }
        //求终结符集合
        for i in 0..<self.GramList.count
        {
            let s=self.GramList[i].rightS;
            for k in s.characters
            {
                if NoendSymbol.indexOf(String(k)) == nil
                {
                    if EndSymbol.indexOf(String(k)) == nil
                    {
                        EndSymbol.append(String(k))
                    }
                }
            }
        }
    }
    
    func CalDFA()
    {
        var DFAstuck:[DFAState]=[];    //dfa状态
        var Gramstuck:[GrammarStruct]=[]    //dfa状态中的文法
        //初始化未处理状态为第一个(A->S)
        var dfastate:DFAState=DFAState();  //当前处理的DFA状态
        dfastate.gram.append(GramList[0])
        dfastate.gram[0].ahead.append("#")
        DFAstuck.append(dfastate)
        var dfanow=0
        while (DFAstuck.count>dfanow)        //dfa状态没处理完
        {
            dfastate=DFAstuck[dfanow]
            Gramstuck.removeAll()   //初始化要求的文法栈
            for i in dfastate.gram
            {
                Gramstuck.append(i)
            }
            var gramnow=0
            while Gramstuck.count>gramnow     //当前dfa状态里的文法没处理完
            {
                let gram:GrammarStruct=Gramstuck[gramnow]
                //当前点所在位置没有下一个字符    肯定没法拓展了
                if (gram.rightS.characters.count == gram.p)
                {
                    gramnow=gramnow+1
                    continue
                }
                //当前点所在位置的下一个字符为非终结符
                if NoendSymbol.indexOf(String(gram.rightS[gram.rightS.startIndex.advancedBy(gram.p)])) != nil
                {
                    for i in 0..<GramList.count
                    {
                        var g:GrammarStruct=GramList[i]     //这里面没有bug了!!!!!!!!!!!!!!
                        g.p=0   //每个扩展的文法初始化，从第一个字符开始
                        //是起始字符
                        if (g.leftS == String(gram.rightS[gram.rightS.startIndex.advancedBy(gram.p)]))
                        {
                            //求展望字符集合
                            if (gram.rightS.characters.count == gram.p+1) || (EndSymbol.indexOf(String(g.rightS[g.rightS.startIndex])) != nil)
                            {
                                g.ahead=gram.ahead
                            }
                            else
                            {
                                //当前的非终结符后面是终结符
                                if (EndSymbol.indexOf(String(gram.rightS[gram.rightS.startIndex.advancedBy(gram.p+1)])) != nil)
                                {
                                    g.ahead.append(String(gram.rightS[gram.rightS.startIndex.advancedBy(gram.p+1)]))
                                }
                                else    //当前的非终结符后面是非终结符???卧槽这是什么情况
                                {
                                    
                                }
                            }
                            var flush:Bool=false            //当前dfa状态中有相同的文法，加入展望字符且更新了当前状态的文法
                            var hasappend:Bool=false    //当当前dfa状态中有相同的文法，则为true
                            var sp=0;
                            for j in 0..<Gramstuck.count
                            {
                                sp=j
                                //发现当前dfa状态中有相同的文法
                                if Gramstuck[j].leftS == g.leftS && Gramstuck[j].rightS == g.rightS && Gramstuck[j].p == g.p
                                {
                                    
                                    hasappend=true
                                    var isexist:Bool=false
                                    for ahead in g.ahead
                                    {
                                        isexist=false
                                        for bhead in Gramstuck[j].ahead
                                        {
                                            if ahead == bhead
                                            {
                                                isexist = true
                                            }
                                        }
                                        if (!isexist)
                                        {
                                            Gramstuck[j].ahead.append(ahead)
                                            flush=true
                                        }
                                    }
                                    break
                                }
                            }
                            if (flush)
                            {
                                if (sp<gramnow)
                                {
                                    Gramstuck.append(Gramstuck[sp])
                                    Gramstuck.removeAtIndex(sp)
                                    gramnow=gramnow-1
                                }
                                else if (sp == gramnow)
                                {
                                    gramnow=gramnow-1
                                }
                            }
                            if (hasappend == false)
                            {
                                Gramstuck.append(g) //加到队列中
                            }
                        }
                    }
                }
                gramnow=gramnow+1
            }
            //求重复
            let findstate=hasDFAState(DFAstuck, gramstuck: Gramstuck,num: dfanow)
            if (findstate >= 0)     //发现重复
            {
                for i in 0..<dfanow
                {
                    dfastate=DFAstuck[i]
                    for j in 0..<dfastate.go.count
                    {
                        let go=dfastate.go[dfastate.go.startIndex.advancedBy(j)]
                        if go.1 == dfanow
                        {
                            DFAstuck[i].go[go.0]=findstate
                        }
                        else if go.1 > dfanow
                        {
                            DFAstuck[i].go[go.0]=DFAstuck[i].go[go.0]!-1
                        }
                    }
                }
                DFAstuck.removeAtIndex(dfanow)
                dfanow=dfanow-1
            }
            else    //没有相同的gram dfa状态
            {
                DFAstuck[dfanow].gram=Gramstuck
                //计算通过它的右部可以到达的集合地方
                for i in 0..<Gramstuck.count
                {
                    var gram=Gramstuck[i]   //当前要求的字符串
                    if (gram.p < gram.rightS.characters.count)  //还能继续往后拓展go数组
                    {
                        let char=String(gram.rightS[gram.rightS.startIndex.advancedBy(gram.p)])
                        gram.p=gram.p+1 //点 后移
                        if DFAstuck[dfanow].go[char] != nil     //已经存在要拓展的字符的集合
                        {
                            var gogram=DFAstuck[DFAstuck[dfanow].go[char]!]
                            gogram.gram.append(gram)
                            DFAstuck[DFAstuck[dfanow].go[char]!]=gogram
                        }
                        else    //新建一个状态
                        {
                            dfastate.go.removeAll()
                            dfastate.gram.removeAll()
                            dfastate.gram.append(gram)
                            let x=DFAstuck.count
                            DFAstuck.append(dfastate)
                            DFAstuck[dfanow].go[char]=x
                        }
                    }
                }
            }
            dfanow=dfanow+1;
        }
        DFA=DFAstuck    //终极赋值哈哈哈！
    }
    
    func hasDFAState(DFAstuck:[DFAState],gramstuck:[GrammarStruct],num:Int)->Int    //判断两个状态是否相等
    {
        for i in 0..<num
        {
            let nowgram=DFAstuck[i].gram
            var isequal:Bool=true
            if (gramstuck.count == nowgram.count)
            {
                for a in gramstuck
                {
                    var has:Bool=false
                    for b in nowgram
                    {
                        if (a.leftS == b.leftS && a.rightS == b.rightS && a.p == b.p )
                        {
                            var ahead = Set<String>()
                            var bhead = Set<String>()
                            for m in a.ahead
                            {
                                ahead.insert(m)
                            }
                            for m in b.ahead
                            {
                                bhead.insert(m)
                            }
                            if ahead == bhead
                            {
                                has = true
                                break
                            }
                        }
                    }
                    if (has == false)
                    {
                        isequal=false
                        break
                    }
                }
                if (isequal)
                {
                    return i
                }
            }
        }
        return -1
    }
    
    func createTable()      //创建表格      Bingo
    {
        var tablecolumn:[String:tablecell]=[:]  //每行元素
        for i in 0..<DFA.count
        {
            tablecolumn=[:]
            let dfastate=DFA[i]
            var cell:tablecell=tablecell(sgr: "", num: 0)
            if dfastate.go.count == 0   //处理r 操作
            {
                for x in 0..<GramList.count
                {
                    if GramList[x].leftS == dfastate.gram[0].leftS && GramList[x].rightS == dfastate.gram[0].rightS
                    {
                        cell.sgr="r"
                        cell.num=x
                        for p in dfastate.gram[0].ahead
                        {
                            tablecolumn[p]=cell
                        }
                    }
                }
            }
            else
            {
                for go in dfastate.go   //处理s / g 操作
                {
                    if NoendSymbol.indexOf(go.0) != nil
                    {
                        cell.sgr="g"
                    }
                    else
                    {
                        cell.sgr="s"
                    }
                    cell.num=go.1
                    tablecolumn[go.0]=cell
                }
            }
            table.append(tablecolumn)
        }
    }
    
    func TestString(s:String)->Bool
    {
        returnStr="状态栈   符号栈   操作  指针所指之后字符\n";
        var statestuck:[Int]=[]
        var charStuck:[String]=[]
        var statetop:Int=0
        statestuck.append(0)
        charStuck.append("#")
        var str=s
        str=str+"#"
        var k:Int=0   //记录当前在第几个字符
        while (1==1)
        {
            let char=String(str[str.startIndex.advancedBy(k)])
            statetop=statestuck.last!
            if (table[statetop][char] == nil)
            {
                return false
            }
            var cell=table[statetop][char]!
            if (cell.sgr == "s")
            {
                charStuck.append(char)
                statestuck.append(cell.num)
                k=k+1
            }
            else if (cell.sgr == "r")
            {
                if (cell.num == 0)
                {
                    if (k == str.characters.count-1)
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
                let len=GramList[cell.num].rightS.characters.count
                for _ in 0..<len
                {
                    charStuck.popLast()
                    statestuck.popLast()
                }
                charStuck.append(GramList[cell.num].leftS)
                statetop=statestuck.last!
                cell=table[statetop][GramList[cell.num].leftS]!
                statestuck.append(cell.num)
            }
            returnStr=returnStr+("\(statestuck)   \(charStuck)   \(cell.sgr)\(cell.num)  \(str.substringFromIndex(str.startIndex.advancedBy(k)))\n")
        }
    }
    
    func maketable()
    {
        var row:[String]=[];
        row.append("");
        for i in 0..<EndSymbol.count
        {
            row.append(EndSymbol[i])
        }
        row.append("#")
        for i in 0..<NoendSymbol.count
        {
            if (NoendSymbol[i] == "A")
            {
                continue
            }
            row.append(NoendSymbol[i])
        }
        atable.append(row)
        for i in 1...table.count
        {
            row=[]
            row.append(String(i-1))
            var state:[String:tablecell]=table[i-1]
            for i in 1...atable[0].count-1
            {
                let char=atable[0][i]
                if state[char] != nil
                {
                    row.append(state[char]!.sgr+String(state[char]!.num))
                }
                else
                {
                    row.append("")
                }
            }
            atable.append(row)
        }
    }
    
}