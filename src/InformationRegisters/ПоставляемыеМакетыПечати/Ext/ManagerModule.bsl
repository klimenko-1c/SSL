﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Процедура ОбновитьКонтрольнуюСуммуМакетов(Параметры) Экспорт
	
	ВерсияМакета = Метаданные.Версия;
	
	Если Параметры.Свойство("МакетыТребующиеОбновленияКонтрольнойСуммы") Тогда
		ОбрабатываемыеМакеты = Параметры.МакетыТребующиеОбновленияКонтрольнойСуммы;
	Иначе
		ОбрабатываемыеМакеты = ВсеМакетыПечатныхФормКонфигурации();
	КонецЕсли;
	
	МакетыТребующиеОбновленияКонтрольнойСуммы = Новый Соответствие;
	СписокОшибок = Новый Массив;
	
	Для Каждого ОписаниеМакета Из ОбрабатываемыеМакеты Цикл
		Владелец = ОписаниеМакета.Значение;
		ИмяВладельца = ?(Владелец = Метаданные.ОбщиеМакеты, "ОбщийМакет", Владелец.ПолноеИмя());
		ИдентификаторОбъектаМетаданныхВладельца = ?(Владелец = Метаданные.ОбщиеМакеты, Неопределено, ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Владелец));
		Макет = ОписаниеМакета.Ключ;
		ИмяМакета = Макет.Имя;
		
		Если Владелец = Метаданные.ОбщиеМакеты Тогда
			ДанныеМакета = ПолучитьОбщийМакет(Макет);
		Иначе
			УстановитьОтключениеБезопасногоРежима(Истина);
			УстановитьПривилегированныйРежим(Истина);
			
			ДанныеМакета = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(Владелец.ПолноеИмя()).ПолучитьМакет(Макет);
			
			УстановитьПривилегированныйРежим(Ложь);
			УстановитьОтключениеБезопасногоРежима(Ложь);
		КонецЕсли;
		
		КонтрольнаяСумма = ОбщегоНазначения.КонтрольнаяСуммаСтрокой(ДанныеМакета);
		
		БлокировкаДанных = Новый БлокировкаДанных;
		ЭлементБлокировкиДанных = БлокировкаДанных.Добавить(Метаданные.РегистрыСведений.ПоставляемыеМакетыПечати.ПолноеИмя());
		ЭлементБлокировкиДанных.УстановитьЗначение("ИмяМакета", ИмяМакета);
		ЭлементБлокировкиДанных.УстановитьЗначение("Объект", ИдентификаторОбъектаМетаданныхВладельца);
		
		НачатьТранзакцию();
		Попытка
			БлокировкаДанных.Заблокировать();
			
			МенеджерЗаписи = РегистрыСведений.ПоставляемыеМакетыПечати.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.ИмяМакета = Макет.Имя;
			МенеджерЗаписи.Объект = ИдентификаторОбъектаМетаданныхВладельца;
			МенеджерЗаписи.Прочитать();
		
			Если Не МенеджерЗаписи.Выбран() Тогда
				МенеджерЗаписи.ИмяМакета = Макет.Имя;
				МенеджерЗаписи.Объект = ИдентификаторОбъектаМетаданныхВладельца;
			КонецЕсли;
			
			Если МенеджерЗаписи.ВерсияМакета = ВерсияМакета Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			
			МенеджерЗаписи.ВерсияМакета = ВерсияМакета;
			МенеджерЗаписи.ПредыдущаяКонтрольнаяСумма = МенеджерЗаписи.КонтрольнаяСумма;
			МенеджерЗаписи.КонтрольнаяСумма = КонтрольнаяСумма;
			МенеджерЗаписи.Записать();
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			
			ТекстОшибки = НСтр("ru = 'Не удалось записать сведения о макете'") + Символы.ПС
				+ Макет.ПолноеИмя() + Символы.ПС
				+ ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
			
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Контроль изменения поставляемых макетов'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка, Макет, , ТекстОшибки);
			
			СписокОшибок.Добавить(ИмяВладельца + "." + ИмяМакета + ": " + КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
			МакетыТребующиеОбновленияКонтрольнойСуммы.Вставить(ОписаниеМакета.Ключ, ОписаниеМакета.Значение);
		КонецПопытки;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(МакетыТребующиеОбновленияКонтрольнойСуммы) Тогда
		СписокОшибок.Вставить(0, НСтр("ru = 'Не удалось записать сведения о макетах печатных форм:'"));
		Параметры.Вставить("МакетыТребующиеОбновленияКонтрольнойСуммы", МакетыТребующиеОбновленияКонтрольнойСуммы);
		ТекстОшибки = СтрСоединить(СписокОшибок, Символы.ПС);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ВсеМакетыПечатныхФормКонфигурации() Экспорт
	
	Результат = Новый Соответствие;
	
	КоллекцииОбъектовМетаданных = Новый Массив;
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.Справочники);
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.Документы);
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.Обработки);
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.БизнесПроцессы);
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.Задачи);
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.ЖурналыДокументов);
	КоллекцииОбъектовМетаданных.Добавить(Метаданные.Отчеты);
	
	Для Каждого КоллекцияОбъектовМетаданных Из КоллекцииОбъектовМетаданных Цикл
		Для Каждого ОбъектМетаданных Из КоллекцияОбъектовМетаданных Цикл
			Для Каждого Макет Из ОбъектМетаданных.Макеты Цикл
				Если СтрНайти(Макет.Имя, "ПФ_") > 0 Тогда
					Результат.Вставить(Макет, ОбъектМетаданных);
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого Макет Из Метаданные.ОбщиеМакеты Цикл
		Если СтрНайти(Макет.Имя, "ПФ_") > 0 Тогда
			Результат.Вставить(Макет, Метаданные.ОбщиеМакеты);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Формирует печатные формы.
//
// Параметры:
//  МассивОбъектов  - Массив    - ссылки на объекты, которые нужно распечатать;
//  ПараметрыПечати - Структура - дополнительные настройки печати;
//  КоллекцияПечатныхФорм - ТаблицаЗначений - сформированные табличные документы (выходной параметр),
//                                            см. УправлениеПечатью.ПодготовитьКоллекциюПечатныхФорм.
//  ОбъектыПечати         - СписокЗначений  - значение - ссылка на объект;
//                                            представление - имя области в которой был выведен объект (выходной
//                                                            параметр);
//  ПараметрыВывода       - Структура       - дополнительные параметры сформированных табличных документов (выходной
//                                            параметр).
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ПечатнаяФорма = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "ИнструкцияПоСозданиюФаксимильнойПодписиИПечати");
	Если ПечатнаяФорма <> Неопределено Тогда
		ПечатнаяФорма.СинонимМакета = НСтр("ru = 'Как сделать факсимильную подпись и печать'");
		ПечатнаяФорма.ТабличныйДокумент = ПолучитьОбщийМакет("ИнструкцияПоСозданиюФаксимильнойПодписиИПечати");
		ПечатнаяФорма.ПолныйПутьКМакету = "ОбщийМакет.ИнструкцияПоСозданиюФаксимильнойПодписиИПечати";
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли