﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// Вызывается при получении уведомления о новых данных.
// В теле следует проверить, необходимы ли эти данные приложению, 
// и если да - установить флажок Загружать.
// 
// Параметры:
//   Дескриптор - ОбъектXDTO - Дескриптор.
//   Загружать - Булево - Истина, если загружать, Ложь - иначе.
//
Процедура ДоступныНовыеДанные(Знач Дескриптор, Загружать) Экспорт
	
	Если Дескриптор.DataType = "БанкиРФ" Тогда
		Загружать = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Вызывается после вызова ДоступныНовыеДанные, позволяет разобрать данные.
//
// Параметры:
//   Дескриптор - ОбъектXDTO - Дескриптор.
//   ПутьКФайлу - Строка - полное имя извлеченного файла. Файл будет автоматически удален 
//                  после завершения процедуры. Если в менеджере сервиса не был
//                  указан файл - значение аргумента равно Неопределено.
//
Процедура ОбработатьНовыеДанные(Знач Дескриптор, Знач ПутьКФайлу) Экспорт
	
	Если Дескриптор.DataType = "БанкиРФ" И ЗначениеЗаполнено(ПутьКФайлу) Тогда
		ИмяОбработки = "ЗагрузкаКлассификатораБанков";
		Если Метаданные.Обработки.Найти(ИмяОбработки) <> Неопределено Тогда
			Обработки[ИмяОбработки].ЗагрузитьДанныеИзФайла(ПутьКФайлу);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Вызывается при отмене обработки данных в случае сбоя.
//
// Параметры:
//   Дескриптор - ОбъектXDTO - Дескриптор.
//
Процедура ОбработкаДанныхОтменена(Знач Дескриптор) Экспорт 
	
	// ничего не надо делать.
	
КонецПроцедуры	

// См. ПоставляемыеДанныеПереопределяемый.ПолучитьОбработчикиПоставляемыхДанных.
Процедура ПриОпределенииОбработчиковПоставляемыхДанных(Обработчики) Экспорт
	
	ЗарегистрироватьОбработчикиПоставляемыхДанных(Обработчики);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Регистрирует обработчики поставляемых данных.
//
// Параметры:
//     Обработчики - ТаблицаЗначений - таблица для добавления обработчиков. Содержит колонки.
//       * ВидДанных - Строка - код вида данных, обрабатываемый обработчиком.
//       * КодОбработчика - Строка - будет использоваться при восстановлении обработки данных после сбоя.
//       * Обработчик - ОбщийМодуль - модуль, содержащий экспортные  процедуры:
//                                          ДоступныНовыеДанные(Дескриптор, Загружать) Экспорт  
//                                          ОбработатьНовыеДанные(Дескриптор, ПутьКФайлу) Экспорт
//                                          ОбработкаДанныхОтменена(Дескриптор) Экспорт
//
Процедура ЗарегистрироватьОбработчикиПоставляемыхДанных(Знач Обработчики)
	
	Обработчик = Обработчики.Добавить();
	Обработчик.ВидДанных = "БанкиРФ";
	Обработчик.КодОбработчика = "ЗагрузкаКлассификатораБанковРФ";
	Обработчик.Обработчик = БанкиСлужебныйВМоделиСервиса;
	
КонецПроцедуры

#КонецОбласти