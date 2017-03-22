//
//  ViewController.swift
//  lr(1)GrammaticalAnalysisStory
//
//  Created by 吴子鸿 on 16/10/23.
//  Copyright © 2016年 吴子鸿. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {
    
    @IBOutlet weak var TableView: NSTableView!
    
    @IBOutlet var ShowText: NSTextView!
    
    @IBOutlet weak var TestText: NSTextField!
    @IBOutlet weak var GramNum: NSTextField!    //产生式个数
    
    @IBOutlet weak var LeftLabel: NSTextField!
    
    @IBOutlet weak var RightLabel: NSTextField!
    var nownum=0
    
    var Num:Int=0
    
    var StartCh:String=""
    
    var GramList:[GrammarStruct]=[]
    
    var grammar:GrammarStruct=GrammarStruct()
    
    var tableviewColumn:[NSTableColumn]=[]
    
    @IBOutlet weak var BeginChar: NSTextField!  //起始字母
    
    @IBOutlet weak var GramLeft: NSTextField!   //产生式左部
    
    @IBOutlet weak var GramRight: NSTextField!  //产生式右部
    
    @IBOutlet weak var SubmitButton: NSButton!
    
    @IBOutlet weak var AddButt: NSButton!
    
    var tableArr:[[String]]=[[]]
    
    var Machine:lr1GrammacticalClass!
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowText.editable=false
        
        for i in TableView.tableColumns
        {
            TableView.removeTableColumn(i)
        }
        tableviewColumn=[]
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func SubmitInit(sender: NSButton) {
        Num=GramNum.integerValue
        StartCh=BeginChar.stringValue
        
        nownum=1;
        LeftLabel.stringValue="第\(nownum)个产生式左部"
        RightLabel.stringValue="第\(nownum)个产生式右部"
        
        SubmitButton.enabled=false
        
    }
    
    
    @IBAction func AddButton(sender: NSButton) {
        if AddButt.title == "计算"
        {
            grammar.leftS=GramLeft.stringValue
            grammar.rightS=GramRight.stringValue
            GramList.append(grammar)
            GramLeft.stringValue = ""
            GramRight.stringValue = ""
            
            Machine=lr1GrammacticalClass(GramList: GramList, schar: self.StartCh)
            
            Machine.CalDFA()
            Machine.createTable()
            Machine.maketable()
            
            self.tableArr=Machine.atable;
            
            ShowText.string=Machine.returnStr
            
            AddButt.enabled=false
            
            //生成二维表

            var newcolumn=NSTableColumn(identifier: String(0))
            newcolumn.width=50
            tableviewColumn.append(newcolumn)
            for i in 1...tableArr[0].count-1    //行头
            {
                newcolumn=NSTableColumn(identifier: String(i))
                newcolumn.width=50
                tableviewColumn.append(newcolumn)
                
            }
            
            
            for column in tableviewColumn
            {
                TableView.addTableColumn(column)
            }
            TableView.reloadData()
            return
        }
        
        nownum=nownum+1
        if (nownum == Num)
        {
            AddButt.title="计算"
        }
        
        grammar.leftS=GramLeft.stringValue
        grammar.rightS=GramRight.stringValue
        GramList.append(grammar)
        
        GramLeft.stringValue = ""
        GramRight.stringValue = ""
        
        LeftLabel.stringValue="第\(nownum)个产生式左部"
        RightLabel.stringValue="第\(nownum)个产生式右部"
        
    }
    
    
    @IBAction func TestButtonClick(sender: NSButton) {
        
        if (Machine.TestString(TestText.stringValue))
        {
            self.ShowText.string=Machine.returnStr
            let myAlert=NSAlert()
            myAlert.messageText="Bingo!"
            myAlert.informativeText="字符串满足文法规则"
            myAlert.alertStyle=NSAlertStyle.InformationalAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
        }
        else
        {
            let myAlert=NSAlert()
            myAlert.messageText="Wrong!"
            myAlert.informativeText="字符串不满足文法规则"
            myAlert.alertStyle=NSAlertStyle.WarningAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
        }
        
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        let column=Int(columnIdentifier)
        if column == nil
        {
            return nil
        }
        let cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
        print (tableArr[row][column!])
        cellView.textField?.stringValue = tableArr[row][column!]
        
        return cellView
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableArr.count
    }
    
    
}

