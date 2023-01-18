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
        })
            .frame(width: 80, height: 50)
            .padding(.horizontal, -8)
    }

    @ViewBuilder func stickers() -> some View {
        if isStickersPresent {
            StickersView()
                .padding(.bottom, -26)
                .padding(.top, 20)
                .offset(y: 290)
        }
    }

    private func dismissInputViews() {
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation {
            isStickersPresent = false
        }
    }

    private func getBottomPadding() -> CGFloat {
        var padding: CGFloat = 25
        padding = isStickersPresent ? 300 : padding
        padding = keyboard.currentHeight == 0 ? padding : keyboard.currentHeight + 8
        return padding
    }

    var body: some View {
        ZStack {
            Constants.background.ignoresSafeArea()

            PlayerView()
                .onAppear {
                    viewModel.startPlayback()
                }

            VStack(spacing: 0) {
                ChatView(selectedMessage: $selectedMessage)
                    .padding(.bottom, 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissInputViews()
                    }

                BottomBarView(viewModel: viewModel, keyboard: keyboard, isLoginPresent: $isLoginPresent, isStickersPresent: $isStickersPresent)
            }
            .overlay(topBar(), alignment: .topTrailing)
            .overlay(NotificationsView(), alignment: .top)
            .overlay(stickers(), alignment: .bottom)
            .padding(.bottom, getBottomPadding())
            .padding(.top, 40)
            .onTapGesture {
                dismissInputViews()
            }
            .sheet(isPresented: $isSettingsPresent, content: {
                SettingsView(viewModel: viewModel, isPresent: $isSettingsPresent)
            })

            if let _ = selectedMessage {
                MessageActionsView(selectedMessage: $selectedMessage)
            }

            if isLoginPresent {
                LoginView(isPresent: $isLoginPresent)
                    .padding(.bottom, keyboard.currentHeight * 0.6)
                    .onChange(of: viewModel.errorMessage) { errorMessage in
                        isLoginPresent = errorMessage == nil
                    }
            }

        }
        .ignoresSafeArea(.all)
        .environmentObject(viewModel)
        .onAppear {
            viewModel.connectToChatRoom()
        }
    }
}
