import UIKit

class DynamicCanvas : NSObject
{
    private var _isRendered : Bool
    private var _numberOfColumns : CGFloat
    private var _numberOfRows : CGFloat
    private var _canvasView : DynamicCanvasView
    private weak var _gridView : UIView!
    
    init(view: UIView)
    {
        self._isRendered = false
        self._numberOfColumns = 12
        self._numberOfRows = 12
        self._canvasView = DynamicCanvasView()
        self._gridView = view
            
        super.init()
    }
    
    var screenSize : CGSize
    {
        get
        {
            let screenSize = UIScreen.main.bounds.size
            
            return screenSize
        }
    }
    
    var gridSize : CGSize
    {
        get
        {
            var gridSize : CGSize! = nil
            
            if (self._gridView != nil)
            {
                gridSize = self._gridView.frame.size
            }
            
            if (gridSize == CGSize.zero)
            {
                gridSize = self.screenSize
            }
            
            return gridSize!
        }
    }
    
    var numberOfHorizontalTiles : CGFloat
    {
        get
        {
            return self.gridSize.height / self.tileLength
        }
    }
    
    var numberOfVerticalTiles : CGFloat
    {
        get
        {
            return self.gridSize.width / self.tileLength
        }
    }
        
    private var tileLength : CGFloat
    {
        get
        {
            return 25
        }
    }
    
    private var columnLength : CGFloat
    {
        get
        {
            return self.gridSize.width / self._numberOfColumns
        }
    }
    
    private var rowLength : CGFloat
    {
        get
        {
            return self.gridSize.height / self._numberOfRows
        }
    }
    
    func draw(tiles: CGFloat) -> CGFloat
    {
        return self.tileLength * tiles
    }
    
    func draw(columns: CGFloat) -> CGFloat
    {
        return self.columnLength * columns
    }
    
    func draw(rows: CGFloat) -> CGFloat
    {
        return self.rowLength * rows
    }
        
    func renderTiles()
    {
        if (self._isRendered)
        {
            self._canvasView = DynamicCanvasView()
            
            for subview in self._gridView!.subviews
            {
                if (subview is DynamicCanvasView)
                {
                    subview.removeFromSuperview()
                }
            }
        }
        
        self._canvasView.frame.size = self.gridSize
        self._canvasView.renderTiles(numberOfVerticalTiles: Int(self.numberOfVerticalTiles),
                                     numberOfHorizontalTiles: Int(self.numberOfHorizontalTiles),
                                     canvas: self)
        self._gridView!.insertSubview(self._canvasView, at: 0)
        self._isRendered = true
    }
    
    func renderColumnsAndRows()
    {
        if (self._isRendered)
        {
            self._canvasView = DynamicCanvasView()
            
            for subview in self._gridView!.subviews
            {
                if (subview is DynamicCanvasView)
                {
                    subview.removeFromSuperview()
                }
            }
        }
        
        self._canvasView.frame.size = self.gridSize
        self._canvasView.renderColumnsAndRows(numberOfColumns: Int(self._numberOfColumns),
                                              numberOfRows: Int(self._numberOfRows),
                                              canvas: self)
        self._gridView!.insertSubview(self._canvasView, at: 0)
        self._isRendered = true
    }
}
