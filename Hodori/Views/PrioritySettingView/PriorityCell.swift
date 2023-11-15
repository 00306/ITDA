//
//  PriorityCell.swift
//  Hodori
//
//  Created by Toughie on 11/7/23.
//

import SwiftUI

struct PriorityCell: View {
    let title: String
    let backColor = #colorLiteral(red: 0.9436392188, green: 0.9436392188, blue: 0.9436392188, alpha: 1)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
            
            HStack(spacing: 0) {
                Image(systemName: "circle")
                    .foregroundStyle(Color.primaryBlue)
                    .font(.pretendRegular14)
                    .fontWeight(.heavy)
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
                
                Text(title)
                    .font(.pretendBold16)
                
                Spacer()
                
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(Color.gray5)
                    .padding(.trailing, 12)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PriorityCell(title: "테스트 안건입니다.")
    }


}
