//
//  ContentView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @ObservedObject private var keyboard = KeyboardResponder()

    @State var isLoginPresent: Bool = false
    @State var isStickersPresent: Bool = false
    @State var isSettingsPresent: Bool = false
    @State var selectedMessage: Message?

    var totalHeight: CGFloat {
        UIScreen.main.bounds.height - keyboard.currentHeight
    }

    @ViewBuilder func topBar() -> some View {
        Button(action: { isSettingsPresent.toggle() }, label: {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .padding(.top, 80)
        })
            .frame(width: 80, height: 50)
            .padding(.horizontal, -8)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Constants.background.ignoresSafeArea()

                PlayerView()
                    .onAppear {
                        viewModel.startPlayback()
                    }

                VStack(spacing: 0) {
                    ChatView(selectedMessage: $selectedMessage)
                        .padding(.bottom, 20)
                    BottomBarView(viewModel: viewModel, keyboard: keyboard, isLoginPresent: $isLoginPresent, isStickersPresent: $isStickersPresent)

                    if isStickersPresent {
                        StickersView()
                            .padding(.bottom, -26)
                            .padding(.top, 20)
                    }
                }
                .overlay(topBar(), alignment: .topTrailing)
                .overlay(NotificationsView(), alignment: .top)
                .animation(.easeOut(duration: 0.3), value: isStickersPresent)
                .frame(maxHeight: geometry.size.height)
                .padding(.bottom, keyboard.currentHeight)
                .onTapGesture {
                    UIApplication.shared
                        .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isStickersPresent = false
                }
                .sheet(isPresented: $isSettingsPresent, content: {
                    SettingsView(viewModel: viewModel, isPresent: $isSettingsPresent)
                })

                if let _ = selectedMessage {
                    MessageActionsView(selectedMessage: $selectedMessage)
                }

                if isLoginPresent {
                    LoginView(isPresent: $isLoginPresent)
                        .padding(.bottom, keyboard.currentHeight * 0.7)
                        .onChange(of: viewModel.errorMessage) { errorMessage in
                            isLoginPresent = errorMessage == nil
                        }
                }

            }
            .ignoresSafeArea(.all)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .environmentObject(viewModel)
            .onAppear {
                viewModel.connectToChatRoom()
            }
        }
    }
}
