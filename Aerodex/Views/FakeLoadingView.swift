//
//  FakeLoadingView.swift
//  Aerodex
//
//  Created by Kayden Wang on 4/12/25.
//

import SwiftUI

struct FakeLoadingView: View {
    var body: some View {
        VStack {
            Text("Fake Loading View")
                .font(.title)
        }
        .onAppear{
            print("Fake Loading View appeared")
        }
    }
}

#Preview {
    FakeLoadingView()
}
