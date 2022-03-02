//
//  Test.swift
//  CookBook
//
//  Created by Michael Abir on 3/1/22.
//

import SwiftUI

struct Test: View {
    @State var _offset: CGFloat = 0
    @State var _lastOffset: CGFloat = 0

    let offset: CGFloat = -100
    @State var vstackOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.red
                .contentShape(
                    Rectangle()
                )
//                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.white)
                
                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.white)

                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.white)

                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.white)
                
                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(Color.white)

            }
            .offset(y: _offset + offset + (vstackOffset - UIScreen.main.bounds.height) / 2 - 10)
            .readSize { size in
                DispatchQueue.main.async {
                    vstackOffset = size.height
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation(.spring()) {
                        _offset = min(-offset, _lastOffset + gesture.translation.height)
                    }
                    
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        _offset = min(0, _offset)
                        _lastOffset = _offset
                    }
                }
        )
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
