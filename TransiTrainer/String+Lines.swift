extension String {
    var firstLine: String {
        let index = startIndex
        let chars = characters
        var d: Data = Data()
        var currentIndex = index
        var toIndex = self.firstLine.index(currentIndex, offsetBy: 1)
        while true {

            toIndex = self.firstLine.index(currentIndex, offsetBy: 1)
            
            if( chars[currentIndex] != "\r\n" && chars[currentIndex] != "\n" && chars[currentIndex] != "\r" ) {
            
            
            // Extract hex code at position fromIndex ..< toIndex:
            let byteString = self.firstLine.substring(with: currentIndex..<toIndex)
            var num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            d.append(&num, count: 1)
            
            // Advance to next position:
            currentIndex = toIndex
            } else { break }
}
        return self.firstLine.substring(to: toIndex)
}
}
