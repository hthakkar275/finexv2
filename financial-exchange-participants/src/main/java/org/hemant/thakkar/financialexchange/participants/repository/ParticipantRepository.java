package org.hemant.thakkar.financialexchange.participants.repository;

import org.hemant.thakkar.financialexchange.participants.domain.Participant;

public interface ParticipantRepository {
	long saveParticipant(Participant participant);
	boolean deleteParticipant(long participantId);
	Participant getParticipant(long participantId);
	int getCount();
}

