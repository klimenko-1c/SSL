﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Вызывается при подтверждении запросов на использование внешних ресурсов.
// 
// Параметры:
//  ИдентификаторыЗапросов - Массив - идентификаторы запросов, которые требуется применить,
//  ФормаВладелец - УправляемаяФорма - форма, которая должна блокироваться до окончания применения разрешений,
//  ОповещениеОЗакрытии - ОписаниеОповещения - которое будет вызвано при успешном предоставлении разрешений.
//  СтандартнаяОбработка - Булево - флаг выполнения стандартной обработки применения разрешений на использование
//    внешних ресурсов (подключение к агенту сервера через COM-соединение или сервер администрирования с
//    запросом параметров подключения к кластеру у текущего пользователя). Может быть установлен в значение Ложь
//    внутри обработчика события, в этом случае стандартная обработка завершения сеанса выполняться не будет.
//
Процедура ПриПодтвержденииЗапросовНаИспользованиеВнешнихРесурсов(Знач ИдентификаторыЗапросов, ФормаВладелец, ОповещениеОЗакрытии, СтандартнаяОбработка) Экспорт
	
	
	
КонецПроцедуры

#КонецОбласти