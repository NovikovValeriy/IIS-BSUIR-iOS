//
//  SaveOmissionsRequestDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct SaveOmissionsRequestDTO: Encodable {
    let idLesson: Int
    let studentOmissionsHoursDtoList: [StudentOmissionHoursDTO]
}

struct StudentOmissionHoursDTO: Encodable {
    let hours: Int
    let student: Int
}
