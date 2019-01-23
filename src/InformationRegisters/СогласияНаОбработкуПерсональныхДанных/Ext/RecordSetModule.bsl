﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СписокСубъектов = Новый Массив;
	ДополнитьСписокСубъектамиПрежнегоНабора(СписокСубъектов);
	ДополнительныеСвойства.Вставить("СписокСубъектов", СписокСубъектов);
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СписокСубъектов = ДополнительныеСвойства["СписокСубъектов"];
	ДополнитьСписокСубъектамиТекущегоНабора(СписокСубъектов);
	ЗащитаПерсональныхДанных.ОбновитьДатыСкрытияПерсональныхДанныхСубъектов(СписокСубъектов);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДополнитьСписокСубъектамиПрежнегоНабора(СписокСубъектов)
	
	Если Не ЗащитаПерсональныхДанных.ИспользоватьСкрытиеПерсональныхДанныхСубъектов() Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Регистратор", Отбор.Регистратор.Значение);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Согласия.Субъект КАК Субъект
		|ИЗ
		|	РегистрСведений.СогласияНаОбработкуПерсональныхДанных КАК Согласия
		|ГДЕ
		|	Согласия.Регистратор = &Регистратор";
	
	Субъекты = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Субъект");
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(СписокСубъектов, Субъекты);
	
КонецПроцедуры

Процедура ДополнитьСписокСубъектамиТекущегоНабора(СписокСубъектов)
	
	Если Не ЗащитаПерсональныхДанных.ИспользоватьСкрытиеПерсональныхДанныхСубъектов() Тогда
		Возврат;
	КонецЕсли;
	
	Субъекты = ВыгрузитьКолонку("Субъект");
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(СписокСубъектов, Субъекты);
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли