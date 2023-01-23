//
//  ErrorView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 28/09/2021.
//  

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var viewModel: ViewModel
    @ObservedObject var network = NetworkConnection()

    var body: some View {
        VStack {
            if !network.isConnected {
                NotificationView(title: "ERROR", image: Image("alert"), message: "No network connection")
            }

            if let error = viewModel.errorMessage {
                NotificationView(title: "ERROR", image: Image("alert"), message: error)
                    .onTapGesture {
                        viewModel.errorMessage = nil
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.messagesTimeout) {
                            viewModel.errorMessage = nil
                        }
                    }
            }

            if let successMessage = viewModel.successMessage {
                NotificationView(
                    title: "SUCCESS",
                    image: Image("info"),
                    message: successMessage,
                    backgroundColor: Constants.appGreen
                )
                    .onTapGesture {
                        viewModel.successMessage = nil
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.messagesTimeout) {
                            viewModel.successMessage = nil
                        }
                    }
            }

            if let infoMessage = viewModel.infoMessage {
                NotificationView(
                    title: "INFO",
                    image: Image("info"),
                    message: infoMessage,
                    backgroundColor: Constants.appBlue
                )
                .onTapGesture {
                    viewModel.infoMessage = nil
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.messagesTimeout) {
                        viewModel.infoMessage = nil
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

struct NotificationView: View {
    var title: String?
    var image: Image?
    var message: String
    var backgroundColor: Color = Color.red

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let image = image {
                    image
                        .resizable()
                        .frame(maxWidth: 15, maxHeight: 15)
                }
                if let title = title {
                    Text(title)
                        .font(Constants.fAppSmall)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 0)
                }
            }
            Text(message)
                .font(Constants.fAppRegular)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
        .foregroundColor(.white)
        .background(backgroundColor)
        .cornerRadius(16)
    }
}
