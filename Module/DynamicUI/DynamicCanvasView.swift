//
//  DynamicCanvasView.swift
//  Pacific
//
//  Created by Minh Nguyen on 10/23/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import UIKit

class DynamicCanvasView : UIView
{
    init()
    {
        super.init(frame: CGRect.zero)
    }
    
    func renderTiles(numberOfVerticalTiles: Int, numberOfHorizontalTiles: Int, canvas: DynamicCanvas)
    {
        for counter in 0...numberOfVerticalTiles
        {
            let tiles = CGFloat(counter)
            let verticalLine = UIView(frame: CGRect(x: canvas.draw(tiles: tiles), y: 0, width: 1, height: self.frame.height))
            verticalLine.backgroundColor = UIColor.orange
            self.addSubview(verticalLine)
        }
        
        for counter in 0...numberOfVerticalTiles - 1
        {
            let tiles = CGFloat(counter)
            let numberLabel = UILabel(frame: CGRect(x: canvas.draw(tiles: tiles), y: 0, width: canvas.draw(tiles: 1), height: canvas.draw(tiles: 1)))
            numberLabel.text = String(counter)
            numberLabel.textColor = UIColor.orange
            numberLabel.font = UIFont.italicSystemFont(ofSize: canvas.draw(tiles: 0.5))
            numberLabel.textAlignment = NSTextAlignment.center
            self.addSubview(numberLabel)
        }
        
        for counter in 0...numberOfHorizontalTiles
        {
            let tiles = CGFloat(counter)
            let horizontalLine = UIView(frame: CGRect(x: 0, y: canvas.draw(tiles: tiles), width: self.frame.width, height: 1))
            horizontalLine.backgroundColor = UIColor.orange
            self.addSubview(horizontalLine)
        }
        
        for counter in 0...numberOfHorizontalTiles - 1
        {
            let tiles = CGFloat(counter)
            let numberLabel = UILabel(frame: CGRect(x: 0, y: canvas.draw(tiles: tiles), width: canvas.draw(tiles: 1), height: canvas.draw(tiles: 1)))
            numberLabel.text = String(counter)
            numberLabel.textColor = UIColor.orange
            numberLabel.font = UIFont.italicSystemFont(ofSize: canvas.draw(tiles: 0.5))
            numberLabel.textAlignment = NSTextAlignment.center
            self.addSubview(numberLabel)
        }
    }
    
    func renderColumnsAndRows(numberOfColumns: Int, numberOfRows: Int, canvas: DynamicCanvas)
    {        
        for counter in 0...numberOfColumns
        {
            let columns = CGFloat(counter)
            let verticalLine = UIView(frame: CGRect(x: canvas.draw(columns: columns), y: 0, width: 1, height: self.frame.height))
            verticalLine.backgroundColor = UIColor.orange
            self.addSubview(verticalLine)
        }
        
        for counter in 0...numberOfColumns - 1
        {
            let columns = CGFloat(counter)
            let numberLabel = UILabel(frame: CGRect(x: canvas.draw(columns: columns), y: 0, width: canvas.draw(columns: 1), height: canvas.draw(rows: 1)))
            numberLabel.text = String(counter)
            numberLabel.textColor = UIColor.orange
            numberLabel.font = UIFont.italicSystemFont(ofSize: canvas.draw(tiles: 0.5))
            numberLabel.textAlignment = NSTextAlignment.center
            self.addSubview(numberLabel)
        }
        
        for counter in 0...numberOfRows
        {
            let rows = CGFloat(counter)
            let horizontalLine = UIView(frame: CGRect(x: 0, y: canvas.draw(rows: rows), width: self.frame.width, height: 1))
            horizontalLine.backgroundColor = UIColor.orange
            self.addSubview(horizontalLine)
        }
        
        for counter in 0...numberOfRows - 1
        {
            let rows = CGFloat(counter)
            let numberLabel = UILabel(frame: CGRect(x: 0, y: canvas.draw(rows: rows), width: canvas.draw(columns: 1), height: canvas.draw(rows: 1)))
            numberLabel.text = String(counter)
            numberLabel.textColor = UIColor.orange
            numberLabel.font = UIFont.italicSystemFont(ofSize: canvas.draw(tiles: 0.5))
            numberLabel.textAlignment = NSTextAlignment.center
            self.addSubview(numberLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
