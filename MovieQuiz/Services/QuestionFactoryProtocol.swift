//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Vlad Mironov2 on 04.01.2025.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
