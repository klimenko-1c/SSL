﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Отправляет SMS через МТС.
//
// Параметры:
//  НомераПолучателей - Массив - номера получателей в формате +7ХХХХХХХХХХ (строкой);
//  Текст             - Строка - текст сообщения, длиной не более 1000 символов;
//  ИмяОтправителя 	  - Строка - имя отправителя, которое будет отображаться вместо номера входящего SMS;
//  Логин             - Строка - логин пользователя услуги отправки sms;
//  Пароль            - Строка - пароль пользователя услуги отправки sms.
//
// Возвращаемое значение:
//  Структура: ОтправленныеСообщения - Массив структур: НомерОтправителя.
//                                                  ИдентификаторСообщения.
//             ОписаниеОшибки    - Строка - пользовательское представление ошибки, если пустая строка,
//                                          то ошибки нет.
Функция ОтправитьSMS(НомераПолучателей, Текст, ИмяОтправителя, Логин, Знач Пароль) Экспорт
	Результат = Новый Структура("ОтправленныеСообщения,ОписаниеОшибки", Новый Массив, "");
	
	Пароль = ОбщегоНазначения.КонтрольнаяСуммаСтрокой(Пароль);
	
	ИдентификаторыПолучателей = Новый Массив;
	Для Каждого Элемент Из НомераПолучателей Цикл
		ИдентификаторПолучателя = ФорматироватьНомер(Элемент);
		Если ИдентификаторыПолучателей.Найти(ИдентификаторПолучателя) = Неопределено Тогда
			ИдентификаторыПолучателей.Добавить(ИдентификаторПолучателя);
		КонецЕсли;
	КонецЦикла;
	
	Попытка
		ВебСервис = ПодключитьВебСервис();
	Исключение
		ОбработатьИсключение(ИнформацияОбОшибке(), Результат.ОписаниеОшибки);
		Возврат Результат;
	КонецПопытки;
	
	ТипArrayOfString = ВебСервис.ФабрикаXDTO.Пакеты.Получить("http://mcommunicator.ru/M2M").Получить("ArrayOfString");
	ArrayOfString = ВебСервис.ФабрикаXDTO.Создать(ТипArrayOfString);
	
	Для Каждого ИдентификаторПолучателя Из ИдентификаторыПолучателей Цикл
		ArrayOfString.string.Добавить(ИдентификаторПолучателя);
	КонецЦикла;
		
	Если ИдентификаторыПолучателей.Количество() > 0 Тогда
		ОтветПолучен = Ложь;
		Попытка
			ArrayOfSendMessageIDs = ВебСервис.SendMessages(ArrayOfString, Лев(Текст, 1000), ИмяОтправителя, Логин, Пароль);
			ОтветПолучен = Истина;
		Исключение
			ОбработатьИсключение(ИнформацияОбОшибке(), Результат.ОписаниеОшибки, Истина, ВебСервис);
			Возврат Результат;
		КонецПопытки;
		
		Если ОтветПолучен Тогда
			Для Каждого SendMessageID Из ArrayOfSendMessageIDs.SendMessageIDs Цикл
				НомерПолучателя = SendMessageID.Msid;
				ИдентификаторСообщения = SendMessageID.MessageID;
				Результат.ОтправленныеСообщения.Добавить(Новый Структура("НомерПолучателя,ИдентификаторСообщения",
					"+" +  НомерПолучателя, Формат(ИдентификаторСообщения, "ЧГ=")));
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

// Возвращает текстовое представление статуса доставки сообщения.
//
// Параметры:
//  ИдентификаторСообщения - Строка - идентификатор, присвоенный sms при отправке;
//  НастройкиОтправкиSMS   - Структура - см. ОтправкаSMSПовтИсп.НастройкиОтправкиSMS;
//
// Возвращаемое значение:
//  Строка - статус доставки. См. описание функции ОтправкаSMS.СтатусДоставки.
Функция СтатусДоставки(ИдентификаторСообщения, НастройкиОтправкиSMS) Экспорт
	Результат = "Ошибка";
	
	Логин = НастройкиОтправкиSMS.Логин;
	Пароль = ОбщегоНазначения.КонтрольнаяСуммаСтрокой(НастройкиОтправкиSMS.Пароль);
	ВебСервис = ПодключитьВебСервис();
	Попытка
		ArrayOfDeliveryInfo = ВебСервис.GetMessageStatus(ИдентификаторСообщения, Логин, Пароль);
	Исключение
		ОбработатьИсключение(ИнформацияОбОшибке(),, Истина, ВебСервис);
		Возврат Результат;
	КонецПопытки;
	
	Для Каждого DeliveryInfo Из ArrayOfDeliveryInfo.DeliveryInfo Цикл
		Результат = СтатусДоставкиSMS(DeliveryInfo.DeliveryStatus);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция ФорматироватьНомер(Номер)
	Результат = "";
	ДопустимыеСимволы = "1234567890";
	Для Позиция = 1 По СтрДлина(Номер) Цикл
		Символ = Сред(Номер,Позиция,1);
		Если СтрНайти(ДопустимыеСимволы, Символ) > 0 Тогда
			Результат = Результат + Символ;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;	
КонецФункции

Функция СтатусДоставкиSMS(СтатусСтрокой)
	СоответствиеСтатусов = Новый Соответствие;
	СоответствиеСтатусов.Вставить("Pending", "НеОтправлялось");
	СоответствиеСтатусов.Вставить("Sending", "Отправляется");
	СоответствиеСтатусов.Вставить("Sent", "Отправлено");
	СоответствиеСтатусов.Вставить("NotSent", "НеОтправлено");
	СоответствиеСтатусов.Вставить("Delivered", "Доставлено");
	СоответствиеСтатусов.Вставить("NotDelivered", "НеДоставлено");
	СоответствиеСтатусов.Вставить("TimedOut", "НеДоставлено");
	
	Результат = СоответствиеСтатусов[СтатусСтрокой];
	Возврат ?(Результат = Неопределено, "Ошибка", Результат);
КонецФункции

Функция ПодключитьВебСервис()
	
	ПараметрыПодключения = ОбщегоНазначения.ПараметрыПодключенияWSПрокси();
	ПараметрыПодключения.АдресWSDL = "https://www.mcommunicator.ru/m2m/m2m_api.asmx?WSDL";
	ПараметрыПодключения.URIПространстваИмен = "http://mcommunicator.ru/M2M";
	ПараметрыПодключения.ИмяСервиса = "MTS_x0020_Communicator_x0020_M2M_x0020_XML_x0020_API";
	ПараметрыПодключения.ИмяТочкиПодключения = "MTS_x0020_Communicator_x0020_M2M_x0020_XML_x0020_APISoap12";
	ПараметрыПодключения.Таймаут = 60;
	ПараметрыПодключения.ЗащищенноеСоединение = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение();
	
	Возврат ОбщегоНазначения.СоздатьWSПрокси(ПараметрыПодключения);
	
КонецФункции

Функция ОписанияОшибок()
	ОписанияОшибок = Новый Соответствие;
	ОписанияОшибок.Вставить("SYSTEM_FAILURE", НСтр("ru = 'Временная проблема на стороне МТС.'"));
	ОписанияОшибок.Вставить("TOO_MANY_PARAMETERS", НСтр("ru = 'Превышено максимальное число параметров.'"));
	ОписанияОшибок.Вставить("INCORRECT_PASSWORD", НСтр("ru = 'Предоставленные логин/пароль не верны.'"));
	ОписанияОшибок.Вставить("MSID_FORMAT_ERROR", НСтр("ru = 'Формат номера неверный.'"));
	ОписанияОшибок.Вставить("MESSAGE_FORMAT_ERROR", НСтр("ru = 'Ошибка в формате сообщения.'"));
	ОписанияОшибок.Вставить("WRONG_ID", НСтр("ru = 'Передан неверный идентификатор.'"));
	ОписанияОшибок.Вставить("MESSAGE_HANDLING_ERROR", НСтр("ru = 'Ошибка в обработке сообщения'"));
	ОписанияОшибок.Вставить("NO_SUCH_SUBSCRIBER", НСтр("ru = 'Данный абонент не зарегистрирован в Услуге в учетной записи клиента (или еще не дал подтверждение).'"));
	ОписанияОшибок.Вставить("TEST_LIMIT_EXCEEDED", НСтр("ru = 'Превышен лимит по количеству сообщений в тестовой эксплуатации.'"));
	ОписанияОшибок.Вставить("TRUSTED_LIMIT_EXCEEDED", НСтр("ru = 'Превышен лимит по количеству сообщений для абонентов, которые были добавлены без подтверждения.'"));
	ОписанияОшибок.Вставить("IP_NOT_ALLOWED", НСтр("ru = 'Доступ к сервису с данного IP невозможен (список допустимых IP-адресов можно указывается при подключении услуги).'"));
	ОписанияОшибок.Вставить("MAX_LENGTH_EXCEEDED", НСтр("ru = 'Превышена максимальная длина сообщения (1000 символов).'"));
	ОписанияОшибок.Вставить("OPERATION_NOT_ALLOWED", НСтр("ru = 'Пользователь услуги не имеет прав на выполнение данной операции.'"));
	ОписанияОшибок.Вставить("EMPTY_MESSAGE_NOT_ALLOWED", НСтр("ru = 'Отправка пустых сообщений не допускается.'"));
	ОписанияОшибок.Вставить("ACCOUNT_IS_BLOCKED", НСтр("ru = 'Учетная запись заблокирована, отправка сообщений не возможна.'"));
	ОписанияОшибок.Вставить("OBJECT_ALREADY_EXISTS", НСтр("ru = 'Список рассылки с указанным названием уже существует в рамках компании.'"));
	ОписанияОшибок.Вставить("MSID_IS_IN_BLACKLIST", НСтр("ru = 'Номер абонента находится в черном списке, отправка сообщений запрещена.'"));
	ОписанияОшибок.Вставить("MSIDS_ARE_IN_BLACKLIST", НСтр("ru = 'Все указанные номера абонентов находятся в черном списке, отправка сообщений запрещена.'"));
	ОписанияОшибок.Вставить("TIME_IS_IN_THE_PAST", НСтр("ru = 'Переданное время в прошлом.'"));
	
	Возврат ОписанияОшибок;
КонецФункции

Функция ОписаниеОшибкиПоКоду(КодОшибки)
	ОписанияОшибок = ОписанияОшибок();
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = НСтр("ru = 'Отказ выполнения операции.'");
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция КодОшибкиИзОписания(Знач ТекстОшибки)
	Результат = Неопределено;
	Позиция = СтрНайти(ТекстОшибки, "<description");
	Если Позиция > 0 Тогда
		ТекстОшибки = Сред(ТекстОшибки, Позиция);
		Позиция = СтрНайти(ТекстОшибки, "</description");
		Если Позиция > 0 Тогда
			ТекстОшибки = Лев(ТекстОшибки, Позиция - 1);
			Позиция = СтрНайти(ТекстОшибки, ">");
			Если Позиция > 0 Тогда
				ТекстОшибки = Сред(ТекстОшибки, Позиция + 1);
				Результат = ТекстОшибки;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Возвращает список разрешений для отправки SMS с использованием всех доступных провайдеров.
//
// Возвращаемое значение:
//  Массив.
//
Функция Разрешения() Экспорт
	Протокол = "HTTPS";
	Адрес = "https://mcommunicator.ru";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Отправка SMS через МТС.'");
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Разрешения = Новый Массив;
	Разрешения.Добавить(
		МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание));
	
	Возврат Разрешения;
КонецФункции

Процедура ЗаполнитьОписаниеУслуги(ОписаниеУслуги) Экспорт
	ОписаниеУслуги.АдресВИнтернете = "http://www.mtscommunicator.ru/service/";
КонецПроцедуры

Процедура ОбработатьИсключение(ИнформацияОбОшибке, ТекстОшибки = Неопределено, ВыполнятьДиагностику = Ложь, ВебСервис = Неопределено)
	
	ЗаписьЖурналаРегистрации(
		НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
		УровеньЖурналаРегистрации.Ошибка,
		,
		,
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
	КодОшибки = КодОшибкиИзОписания(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
	Если КодОшибки = Неопределено Тогда 
		
		Если ВыполнятьДиагностику Тогда 
			АдресТочкиПодключения = ВебСервис.ТочкаПодключения.Местоположение;
			РезультатДиагностики = ПолучениеФайловИзИнтернета.ДиагностикаСоединения(АдресТочкиПодключения);
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = '%1
				           |
				           |Результат диагностики:
				           |%2'"),
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке),
				РезультатДиагностики.ОписаниеОшибки);
		Иначе 
			ТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
		КонецЕсли;
		
	Иначе 
		ТекстОшибки = ОписаниеОшибкиПоКоду(КодОшибки);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
